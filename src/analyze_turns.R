# analyze_turns.R
# Tiffany Timbers, Oct 15, 2016

# load libraries
library(tidyverse)

# get command args
args <- commandArgs(trailingOnly = TRUE)
rev_file <- args[1] #"data/all_reverals_parsed.rev"
good_number_file <- args[2] "data/all_good_numbers_parsed.dat"
output_file_prefix <- args[3] 

main <- function(){
  
  # read in data
  rev_data <- read_csv(rev_file)
  good_number_data <- read_csv(good_number_file)
  
  # make tidy data frame
  
  
  # make vis and write to file
  
  # do stats and write to file

  
}

main()