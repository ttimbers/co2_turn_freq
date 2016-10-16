# quick body size plot

# load libraries
library(tidyverse)

# get command args
args <- commandArgs(trailingOnly = TRUE)
body_size_file <- args[1] 
output_file_prefix <- args[2] 

main <- function(){
 
  # read in data
  size_data <- read_csv(body_size_file)
  
  length_data <- size_data %>% 
    group_by(strain, plate) %>% 
    filter(time > 70, time < 100) %>% 
    summarise(mean_length = mean(midline),
                        sd_length = sd(midline),
                        se_lenth = sd(midline) / sqrt(n()),
                        ci_length = (sd(midline) / sqrt(n()) * 1.96))
  
  length_plot <- ggplot(length_data, aes(strain, mean_length)) + 
    geom_boxplot() +
    ylim(c(0.75, 1)) +
    labs(x="Strain", y="Length (mm)") 
  
  output_length_plot_name <- paste0(output_file_prefix, "_length_plot.pdf")
  ggsave(output_length_plot_name, length_plot, height = 3, width = 3)
  
  print(summary(aov(mean_length ~ strain, length_data)))
}