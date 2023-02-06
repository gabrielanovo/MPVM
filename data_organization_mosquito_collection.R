library(tidyverse) 
library(ggthemes)
library(readr)
library(plyr)
library(dplyr)
library(lubridate)
library(data.table)

##### LOADING DATASETS #####

sacyolo_mosquito_collections_2006to2011 <- read.csv('~/Downloads/DART/Project/DATA/sac-yolo_mosquito_collections_2006-2011.csv')

sacyolo_mosquito_collections_2012to2017 <- read.csv('~/Downloads/DART/Project/DATA/sac-yolo_mosquito_collections_2012-2017.csv')

sacyolo_mosquito_collections_2018to2021 <- read.csv('~/Downloads/DART/Project/DATA/sac-yolo_mosquito_collections_2018-2021.csv')

##### EDITTING THE MOSQUITO COLLECTION DATASET #####
sacyolo_mosquito_collections_2006to2011_filtered <- sacyolo_mosquito_collections_2006to2011 [
  c('agency_code','agency_collection_num','collection_id','code','street','city','zip','region',
    'site_code','site_name','site_street','site_city','site_zip','site_region','calculated_city',
    'calculated_subcounty','calculated_county','longitude','latitude','coordinate_precision',
    'trap_type','lure','collection_date','num_trap' ,'trap_nights','trap_problem','comments',
    'add_date','add_user','culex_tarsalis_females.mixed','culex_tarsalis_males','culex_tarsalis_',
    'culex_tarsalis_females.bloodfed','culex_tarsalis_females.unfed','culex_tarsalis_females.gravid',
    'culex_tarsalis_unknownsex','culex_pipiens_females.mixed','culex_pipiens_males','culex_pipiens_',
    'culex_pipiens_females.bloodfed','culex_pipiens_females.unfed','culex_pipiens_females.gravid',
    'culex_pipiens_unknownsex')]%>%
  add_column(culex_tarsalis_eggs=NA)%>%
  add_column(culex_tarsalis_larvae=NA)%>%
  add_column(culex_tarsalis_pupae=NA)%>%
  add_column(culex_tarsalis_nymph=NA)%>%
  add_column(culex_pipiens_eggs=NA)%>%
  add_column(culex_pipiens_larvae=NA)%>%
  add_column(culex_pipiens_pupae=NA)%>%
  add_column(culex_pipiens_nymph=NA)


sacyolo_mosquito_collections_2012to2017_filtered <- sacyolo_mosquito_collections_2012to2017 [
  c('agency_code','agency_collection_num','collection_id','code','street','city','zip','region',
    'site_code','site_name','site_street','site_city','site_zip','site_region','calculated_city',
    'calculated_subcounty','calculated_county','longitude','latitude','coordinate_precision',
    'trap_type','lure','collection_date','num_trap' ,'trap_nights','trap_problem','comments',
    'add_date','add_user','culex_tarsalis_males','culex_tarsalis_females.mixed','culex_tarsalis_',
    'culex_tarsalis_females.unfed','culex_tarsalis_unknownsex','culex_tarsalis_eggs',
    'culex_tarsalis_larvae','culex_pipiens_males','culex_pipiens_females.mixed','culex_pipiens_',
    'culex_pipiens_females.unfed','culex_pipiens_unknownsex','culex_pipiens_eggs','culex_pipiens_larvae')] %>%
  add_column(culex_tarsalis_females.bloodfed = NA) %>%
  add_column(culex_tarsalis_females.gravid =NA) %>%
  add_column(culex_pipiens_females.bloodfed=NA)%>%
  add_column(culex_pipiens_females.gravid=NA)%>%
  add_column(culex_tarsalis_pupae=NA)%>%
  add_column(culex_tarsalis_nymph=NA)%>%
  add_column(culex_pipiens_pupae=NA)%>%
  add_column(culex_pipiens_nymph=NA)


sacyolo_mosquito_collections_2018to2021_filtered <- sacyolo_mosquito_collections_2018to2021 [
  c('agency_code','agency_collection_num','collection_id','code','street','city','zip','region',
    'site_code','site_name','site_street','site_city','site_zip','site_region','calculated_city',
    'calculated_subcounty','calculated_county','longitude','latitude','coordinate_precision','trap_type',
    'lure','collection_date','num_trap' ,'trap_nights','trap_problem','comments','add_date','add_user',
    'culex_tarsalis_males','culex_tarsalis_females.mixed','culex_tarsalis_','culex_tarsalis_females.unfed',
    'culex_tarsalis_females.gravid','culex_tarsalis_eggs','culex_tarsalis_larvae','culex_tarsalis_unknownsex',
    'culex_tarsalis_pupae','culex_tarsalis_females.bloodfed','culex_tarsalis_nymph','culex_pipiens_males',
    'culex_pipiens_females.mixed','culex_pipiens_','culex_pipiens_females.unfed','culex_pipiens_females.gravid',
    'culex_pipiens_eggs','culex_pipiens_larvae','culex_pipiens_unknownsex','culex_pipiens_pupae',
    'culex_pipiens_females.bloodfed','culex_pipiens_nymph')]

sacyolo_mosquito_collections_2006to2021 <- rbind(
  sacyolo_mosquito_collections_2006to2011_filtered, sacyolo_mosquito_collections_2012to2017_filtered, 
  sacyolo_mosquito_collections_2018to2021_filtered)

sacyolo_mosquito_collections_2006to2021$culex_tarsalis_females = rowSums(
  sacyolo_mosquito_collections_2006to2021[
    ,grep('culex_tarsalis_females',names(sacyolo_mosquito_collections_2006to2021))
  ],na.rm=TRUE)

sacyolo_mosquito_collections_2006to2021$culex_pipiens_females = rowSums(
  sacyolo_mosquito_collections_2006to2021[
    ,grep('culex_pipiens_females',names(sacyolo_mosquito_collections_2006to2021))
  ],na.rm=TRUE)

#defining 'collection_date' as a date variable
sacyolo_mosquito_collections_2006to2021$collection_date = as.Date(sacyolo_mosquito_collections_2006to2021$collection_date)

#renaming 'collection_date' as 'date'
sacyolo_mosquito_collections_2006to2021 <- sacyolo_mosquito_collections_2006to2021 %>%
  mutate(date=collection_date)

#sacyolo_mosquito_collections_2006to2021$study_week = ceiling(as.integer(
#  (sacyolo_mosquito_collections_2006to2021$date-as.Date('2005-12-31'))/7))

#creating year, month and week variables
sacyolo_mosquito_collections_2006to2021$year = year(sacyolo_mosquito_collections_2006to2021$date)

sacyolo_mosquito_collections_2006to2021$month = month(sacyolo_mosquito_collections_2006to2021$date)

sacyolo_mosquito_collections_2006to2021$week = week(sacyolo_mosquito_collections_2006to2021$date)

#ignoring 53rd week of leap years using the epiweek function from lubridate 
sacyolo_mosquito_collections_2006to2021 = subset(sacyolo_mosquito_collections_2006to2021,
                                                 epiweek(sacyolo_mosquito_collections_2006to2021$date)<=52)

#creating study_week variable ranging from the 1st week of 2006 to the last week of 2021
sacyolo_mosquito_collections_2006to2021$study_week = (epiyear(sacyolo_mosquito_collections_2006to2021$date)-2006
                                                      )*52+epiweek(sacyolo_mosquito_collections_2006to2021$date)

#Aggregate data by date and subcounty
collection_data_epiweek <- ddply(sacyolo_mosquito_collections_2006to2021, 
                         c('year','week','calculated_subcounty'),
                         summarise, 
                         total_culex_tarsalis_females = sum(culex_tarsalis_females), 
                         total_culex_pipiens_females = sum(culex_pipiens_females),
                         total_num_traps=sum(num_trap),total_trap_nights=sum(trap_nights))

rm(sacyolo_mosquito_collections_2006to2011,
   sacyolo_mosquito_collections_2006to2011_filtered,
   sacyolo_mosquito_collections_2012to2017,
   sacyolo_mosquito_collections_2012to2017_filtered,
   sacyolo_mosquito_collections_2018to2021,
   sacyolo_mosquito_collections_2018to2021_filtered)

