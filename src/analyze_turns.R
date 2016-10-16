# analyze_turns.R
# Tiffany Timbers, Oct 15, 2016

# load libraries
library(tidyverse)
library(peakPick)

# get command args
args <- commandArgs(trailingOnly = TRUE)
body_size_file <- args[1] #"data/all_body_size_parsed.dat"
good_number_file <- args[2] "data/all_good_numbers_parsed.dat"
output_file_prefix <- args[3] 

main <- function(){
  
  # read in data
  size_data <- read_csv(body_size_file)
  good_number_data <- read_csv(good_number_file)
  
  # detect high amplitude turns (M/m)
  turns_data <- size_data 
  turns_data$aspect_ratio <- turns_data$morphwidth / turns_data$midline 
  
  # Detect Peaks of M/m (min_peak_height = 0.25, min_peak_distance = 90)
   
  # split by plate, & id  
  turns_data <- turns_data %>% 
    #filter(strain == "N2", plate == "20130524_140719") %>% 
    group_by(plate, id) %>% 
    nest() %>% 
    mutate(turns = map(data, detect_HA_turns)) %>% 
    filter(!is.na(turns)) %>% 
    select(turns) %>% 
    unnest()

  # make tidy data frame to combine size_data & good_number_data
  
  
  # make vis and write to file
  
  # do stats and write to file

  
}

# Detects high-amplitude (HA) turns (a C. elegans response to CO2)
#
# Inputs:
#   x  = a data frame with columns named time & aspect_ratio (morphwidth / midline)
#   min_peak_height = minimum aspect ratio to be considered a HA turn (default = 0.25)
#   min_peak_distance = minimum peak distance (in sec) between turns (default = 90)
#
# Returns: a data frame containing only the records where peaks occurred
detect_HA_turns <- function(x, min_peak_height = 0.25, min_peak_distance = 90) {
  
  if (max(x$aspect_ratio > 0.25)) { 
    x_ts <- as.matrix(select(x, time, aspect_ratio))
    # neighlim = (min_peak_distance * 25) because neighlim is integer val, and camera
    # records at ~ 25 frames/sec
    peaks_bool <- peakpick(x_ts, neighlim = (min_peak_distance * 25), peak.npos = 50)
  } else {
      return (NA) # if this fails, try returning an empty tibble via tibble()
    }

  turns <- filter(x, peaks_bool[,2], aspect_ratio > min_peak_height)
  
  return(turns)
}

main()