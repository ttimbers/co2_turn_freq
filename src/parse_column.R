# parse_column.R
# Tiffany Timbers, Oct 15, 2016

# load libraries
library(stringr)
library(tidyverse)
library(testit)

# get command args
args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
output_file <- args[2] 

main <- function(){
  # read in data
  data <- read.table(input_file, header = FALSE)
  
  # parse column 
  parsed_column <- parse_col(data$V1)
  data_no_column_1 <- data
  data_no_column_1$V1 <- NULL
  
  ## combine new columns with merged file
  parsed_data <- bind_cols(parsed_column, data_no_column_1)
  
  # rename columns
  assert("You should provide the column names of the choreography file", length(args) > 3)
  colnames(parsed_data)[4:ncol(parsed_data)] <- args[3:length(args)]
  
  # write data
  write_csv(parsed_data, output_file)
}

# function for parsing date, plate and strain name from grep -H of output choreography files
# Input: a character vector
# Returns: a data frame with columns date, plate, strain and time

parse_col <- function(x){
  # regex to make vectors
  date <- str_extract(x, "[0-9]{8}")
  plate <- str_extract(x, "[0-9]{8}_[0-9]{6}")
  col_1 <- str_extract(x, ":[0-9]+[.]?[0-9]+")
  col_1 <- sub(":", "", col_1)
  strain <- str_extract(x,"[A-Za-z]+[-]?[0-9]+")
  
  # put vectors together & return data_frame
  new_data <- data.frame(date, plate, strain, col_1)  
  return(new_data)
}

main()