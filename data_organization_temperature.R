library(tidyverse) 
library(ggthemes)
library(readr)
library(plyr)
library(dplyr)
library(lubridate)
library(data.table)


##### LOADING DATASETS #####

temperature_data_by_county_subdivision <- read.csv('~/Downloads/DART/Project/DATA/temperature_data_by_county_subdivision.csv')

### EDITTING THE TEMPERATURE DATASET ###

#renaming the date and location variables to match with our collection dataset (as 'date' and 'calculated_subcounty')
temperature_data_by_county_subdivision$date = as.Date(temperature_data_by_county_subdivision$record_date)

temperature_data_by_county_subdivision$calculated_subcounty = temperature_data_by_county_subdivision$name

#creating year, month and week variables
temperature_data_by_county_subdivision$year = year(temperature_data_by_county_subdivision$date)

temperature_data_by_county_subdivision$month = month(temperature_data_by_county_subdivision$date)

temperature_data_by_county_subdivision$week = week(temperature_data_by_county_subdivision$date)

temperature_data_epiweek <- ddply(temperature_data_by_county_subdivision, 
                                  c('week','calculated_subcounty','year'), 
                                  summarise, 
                                  min_temp=mean(tmin), 
                                  max_temp=mean(tmax),
                                  mean_temp=mean(tmean))
