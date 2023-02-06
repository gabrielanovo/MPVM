source("~/Downloads/DART/Project/Code/data_organization_mosquito_collection.R")
source("~/Downloads/DART/Project/Code/data_organization_temperature.R")

# merging the collection and temperature datasets
collection_temperature_epiweek = left_join(collection_data_epiweek, temperature_data_epiweek, 
                                    by = c("calculated_subcounty","week","year"))

collection_temperature_epiweek = as.data.frame(collection_temperature_epiweek)

collection_temperature_epiweek <- collection_temperature_epiweek %>%
  mutate(tars_trapnight = total_culex_tarsalis_females/(total_num_traps*total_trap_nights))%>%
  mutate(pipiens_trapnight = total_culex_pipiens_females/(total_num_traps/total_trap_nights))%>%
  filter(calculated_subcounty != 'Clarksburg' & calculated_subcounty != 'Dixon')


#we lost the 'date' variable during the merging process so we will recreate it now using the function created below

epiweekToDate<-function(year,weekno,firstday="Sunday"){
  if(!(firstday=="Sunday"|| firstday=="Monday")){
    print("Wrong firstday!")
    break
  }
  if(year<0 || weekno<0){
    print("Wrong Input!")
    break
  }
  
  jan4=strptime(paste(year,1,4,sep="-"),format="%Y-%m-%d")
  wday=jan4$wday
  wday[wday==0]=7
  wdaystart=ifelse(firstday=="Sunday",7,1)
  if(wday== wdaystart) weekstart=jan4
  if(wday!= wdaystart) weekstart=jan4-(wday-ifelse(firstday=="Sunday",0,1))*86400
  
  jan4_2=strptime(paste(year+1,1,4,sep="-"),format="%Y-%m-%d")
  
  wday_2=jan4_2$wday
  wday_2[wday_2==0]=7
  wdaystart_2=ifelse(firstday=="Sunday",7,1)
  if(wday_2== wdaystart_2) weekstart_2=jan4_2
  if(wday_2!= wdaystart_2) weekstart_2=jan4_2-(wday_2-ifelse(firstday=="Sunday",0,1))*86400
  
  if(weekno>((weekstart_2-weekstart)/7)){
    print(paste("There are only ",(weekstart_2-weekstart)/7," weeks in ",year,"!",sep=""))
    break
  }
  
  d0=weekstart+(weekno-1)*7*86400
  d1=weekstart+(weekno-1)*7*86400+6*86400
  
  return(list("d0"=strptime(d0,format="%Y-%m-%d"),"d1"=strptime(d1,format="%Y-%m-%d")))
}

#applying the function to the data
collection_temperature_epiweek <- collection_temperature_epiweek %>%
  mutate(date = make_datetime(year = collection_temperature_epiweek$year) + weeks(collection_temperature_epiweek$week))

#defining 'date' as a date variable
collection_temperature_epiweek$date = as.Date(collection_temperature_epiweek$date)

#recreating the 'study_week' and 'month' variables based on our new 'date' variable
collection_temperature_epiweek$study_week = (epiyear(collection_temperature_epiweek$date)-2006
)*52+epiweek(collection_temperature_epiweek$date)
  # another way to do it:
    # collection_temperature_epiweek$study_week = ceiling(as.integer((collection_temperature_epiweek$date-as.Date('2005-12-31'))/7))

collection_temperature_epiweek$month = month(collection_temperature_epiweek$date)

#reordering the variables
col_order <- c('calculated_subcounty','study_week','month','week','year','min_temp','max_temp','mean_temp',
               'total_culex_tarsalis_females','total_culex_pipiens_females','total_num_traps',
               'total_trap_nights','tars_trapnight','pipiens_trapnight'
               )

collection_temperature_epiweek <- collection_temperature_epiweek[,col_order]%>%
  arrange(calculated_subcounty,study_week)

saveRDS(collection_temperature_epiweek,'~/Downloads/DART/Project/DATA/syabund.rds')
