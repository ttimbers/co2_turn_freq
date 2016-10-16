# analyze_turns.R
# Tiffany Timbers, Oct 15, 2016

# load libraries
library(tidyverse)
library(peakPick)
library(stringr)

# get command args
args <- commandArgs(trailingOnly = TRUE)
body_size_file <- args[1] 
good_number_file <- args[2]
output_file_prefix <- args[3] 

main <- function(){
  
  # read in data
  size_data <- read_csv(body_size_file)
  good_number_data <- read_csv(good_number_file)
  
  # detect high amplitude turns (M/m)
  turns_data <- size_data 
  turns_data$aspect_ratio <- turns_data$morphwidth / turns_data$midline 
  
  # Detect Peaks of M/m (min_peak_height = 0.25, min_peak_distance = 90)
  turns_data <- turns_data %>% 
    group_by(plate, id) %>% 
    nest() %>% 
    mutate(turns = map(data, detect_HA_turns)) %>% 
    filter(!is.na(turns)) %>% 
    select(turns, id, plate) %>% 
    unnest()
  
  
  # Determine the number of turns/minute per worm 
  
  # calculate mean N at each time interval
  time_interval <- seq(from = 0, to = 300, by = 20)
  
  # calculate turns per per plate per time bin
  turns_by_interval <- turns_data %>% 
    mutate(interval = cut(time, time_interval)) %>% 
    group_by(plate, strain, interval) %>% 
    summarise(turns = n())
  
  # calculate good number per plate per time bin
  good_number_by_interval <- good_number_data %>% 
    mutate(interval = cut(time, time_interval)) %>% 
    group_by(plate, strain, interval) %>% 
    summarise(count = round(mean(good_number)))
  
  # create dataframe to get turns/min for each time bin
  turns_min <- left_join(good_number_by_interval, turns_by_interval)
  turns_min$turns[is.na(turns_min$turns)] <- 0
  turns_min$tpm <- (turns_min$turns / turns_min$count) * 3
  
  # create summarised data frame to plot mean turns/min for each time bin
  turns_min_agg <- turns_min %>% 
    group_by(strain, interval) %>% 
    summarise(mean_tpm = median(tpm),
              sd_tpm = sd(tpm),
              se_tpm = sd(tpm) / sqrt(n()),
              ci_tpm = (sd(tpm) / sqrt(n()) * 1.96)) 
  
  turns_min_agg$interval <- as.numeric(str_extract(turns_min_agg$interval, "[1-9]{1}[0-9]+"))
  turns_min_agg$interval[is.na(turns_min_agg$interval)] <- 300
  turns_min_agg$interval <- turns_min_agg$interval + 10 #set to mid of time bin
  
  # make vis and write to file
  ha_plot <- ggplot(turns_min_agg, aes(y = mean_tpm, x = interval, colour = strain)) + 
    geom_errorbar(aes(ymin = mean_tpm - ci_tpm, ymax = mean_tpm + ci_tpm)) +
    geom_line(aes(group = strain)) + 
    geom_point() +
    labs(x="Time", y="High amplitude turns/minute") 
  
  output_ha_plot_name <- paste0(output_file_prefix, "_ha_plot.pdf")
  ggsave(output_ha_plot_name, ha_plot, height = 3, width = 5)
  
  # do stats and write to file
  turns_min$interval <- as.numeric(str_extract(turns_min$interval, "[1-9]{1}[0-9]+"))
  turns_min$interval[is.na(turns_min$interval)] <- 300
  turns_min$interval <- turns_min$interval + 10 #set to mid of time bin
  
  # convert chr to factor to do stats
  turns_min$interval <- as.factor(turns_min$interval)
  turns_min$plate <- as.factor(turns_min$plate)
  turns_min$strain <- as.factor(turns_min$strain)
  
  repeated_measures_anova <- aov(tpm ~ strain + Error(interval / strain), data = turns_min)
  print(summary(repeated_measures_anova))
}

# Detects high-amplitude (HA) turns (a C. elegans response to CO2)
#
# Inputs:
#   x  = a data frame with columns named time & aspect_ratio (morphwidth / midline)
#   min_peak_height = minimum aspect ratio to be considered a HA turn (default = 0.25)
#   min_peak_distance = minimum peak distance (in sec) between turns (default = 90)
#
# Returns: a data frame containing only the records where peaks occurred, if there was 
#          no peak, it returns NA
detect_HA_turns <- function(x, min_peak_height = 0.25, min_peak_distance = 90) {
  
  if (max(x$aspect_ratio > min_peak_height)) { 
    x_ts <- as.matrix(select(x, time, aspect_ratio))
    # neighlim = (min_peak_distance * 25) because neighlim is integer val, and camera
    # records at ~ 25 frames/sec
    peaks_bool <- peakpick(x_ts, neighlim = (min_peak_distance * 25), peak.npos = 50)
  } else {
      return (NA)
    }

  turns <- filter(x, peaks_bool[,2], aspect_ratio > min_peak_height)
  return(turns)
}

main()