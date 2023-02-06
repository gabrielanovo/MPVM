library(tidyverse) 
library(ggthemes)
library(readr)
library(plyr)
library(dplyr)
library(lubridate)
library(data.table)

##### LOADING DATASETS #####
sacyolo_mosquito_collections_pools_results_2006to2021 <- read.csv('~/Downloads/DART/Project/DATA/sac-yolo_mosquito_pool_test_results.csv')

sacyolo_mosquito_collections_pools_results_2006to2021$date = as.Date(sacyolo_mosquito_collections_pools_results_2006to2021$collection_date,'%m/%d/%y')

#Creating a variable for year, month and week of each date
sacyolo_mosquito_collections_pools_results_2006to2021$year = year(sacyolo_mosquito_collections_pools_results_2006to2021$date)
sacyolo_mosquito_collections_pools_results_2006to2021$month = month(sacyolo_mosquito_collections_pools_results_2006to2021$date)
sacyolo_mosquito_collections_pools_results_2006to2021$week = week(sacyolo_mosquito_collections_pools_results_2006to2021$date)

#Ignoring the 53rd week of leap years

sacyolo_mosquito_collections_pools_results_2006to2021 = subset(sacyolo_mosquito_collections_pools_results_2006to2021,epiweek(sacyolo_mosquito_collections_pools_results_2006to2021$date)<=52)



#Creating a variable called "study_week" (which enumerates the weeks starting on 12/31/2005)
sacyolo_mosquito_collections_pools_results_2006to2021$study_week = (epiyear(sacyolo_mosquito_collections_pools_results_2006to2021$date)-2006
                                                                    )*52+epiweek(sacyolo_mosquito_collections_pools_results_2006to2021$date)

#renaming 'subcounty' as 'calculated_subcounty' to match the other dataset
sacyolo_mosquito_collections_pools_results_2006to2021 <- sacyolo_mosquito_collections_pools_results_2006to2021 %>%
  mutate(calculated_subcounty=subcounty)

#Creating a dataset for pools targeting WNV only, and only including C. tarsalis and C. pipiens
sacyolo_pools_WNV <- sacyolo_mosquito_collections_pools_results_2006to2021 %>%
  filter(test_target=='WNV') %>%
  filter(species %in% c('Culex tarsalis','Culex pipiens')) %>%
  filter(sex=='female') %>% #there was only 1 non-female, which was unknown sex 
  filter(!calculated_subcounty %in% c('Clarksburg','Dixon')) 

#Keeping only columns of interest
sacyolo_pools_wnv <- sacyolo_pools_WNV[,c('calculated_subcounty','study_week','month','week','year','trap_type', 'species', 'num_count','test_status')]

#Coding "positive" and "negative" pools as 1 and 0
sacyolo_pools_wnv <- sacyolo_pools_wnv %>%
  mutate (number_positive_pools = ifelse(test_status=='Negative',0,1))%>%
  mutate (number_of_pools=1)%>%
  arrange(calculated_subcounty,study_week)%>%
  dplyr::rename (size_of_pools = num_count)

saveRDS(sacyolo_pools_wnv,'~/Downloads/DART/Project/DATA/sypools.rds')
