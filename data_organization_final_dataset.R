library(data.table)
library(plyr)
library(dplyr)
library(PooledInfRate)
library(tidyverse)
library(ggthemes)

#run the following codes to obtain the data or upload the data directly
# source("~/Downloads/DART/Project/Code/data_organization_abundance.R")
# source("~/Downloads/DART/Project/Code/data_organization_pools.R")

#loading the datasets
syabund = readRDS('~/Downloads/DART/Project/Data/syabund.rds')
sypools = readRDS('~/Downloads/DART/Project/Data/sypools.rds')

syp.tarsalis = subset(sypools,sypools$species == 'Culex tarsalis')
syp.pipiens = subset(sypools,sypools$species == 'Culex pipiens')

syp.tarsalis = data.table(syp.tarsalis)
syp.pipiens = data.table(syp.pipiens)


syp.tarsalis.group = syp.tarsalis [,.(tars_mosquitoes_tested = sum(size_of_pools),
                                               tars_pools_tested = sum(number_of_pools),
                                               tars_pools_tested_positive = sum(number_positive_pools)),
                                     by=list(calculated_subcounty,study_week)]
mutate(syp.tarsalis.group,
       tars_prev = 
         ifelse(sum(syp.tarsalis.group$number_positive_pools) == sum(syp.tarsalis.group$number_of_pools),
                sum(syp.tarsalis.group$number_positive_pools)/sum(syp.tarsalis.group$size_of_pools),
                ifelse(sum(syp.tarsalis.group$number_positive_pools) == 0,
                       0,
                       pooledBin(x=syp.tarsalis.group$number_positive_pools,
                                 m=syp.tarsalis.group$size_of_pools,
                                 n=syp.tarsalis.group$number_of_pools,
                                 pt.method='mir')$p)))

# alternative code for the two last codes above (for some reason this code works for some people but not for others):
#   syp.tarsalis.group = syp.tarsalis[,
#                                   .(tars_mosquitoes_tested = sum(size_of_pools),
#                                     tars_pools_tested = sum(number_of_pools),
#                                     tars_pools_tested_positive = sum(number_positive_pools),
#                                     tars_prev = ifelse(sum(number_positive_pools) == sum(number_of_pools),
#                                                        sum(number_positive_pools)/sum(size_of_pools),
#                                                        ifelse(sum(number_positive_pools) == 0,
#                                                               0,
#                                                               pooledBin(x=number_positive_pools,m=size_of_pools,n=number_of_pools,pt.method='mir')$p))),
#                                   by=list(calculated_subcounty,study_week)]
      
      
syp.pipiens.group = syp.pipiens [,.(pipi_mosquitoes_tested = sum(size_of_pools),
                                      pipi_pools_tested = sum(number_of_pools),
                                      pipi_pools_tested_positive = sum(number_positive_pools)),
                                   by=list(calculated_subcounty,study_week)]
mutate(syp.pipiens.group,
       pipi_prev = 
         ifelse(sum(syp.pipiens.group$number_positive_pools) == sum(syp.pipiens.group$number_of_pools),
                sum(syp.pipiens.group$number_positive_pools)/sum(syp.pipiens.group$size_of_pools),
                ifelse(sum(syp.pipiens.group$number_positive_pools) == 0,
                       0,
                       pooledBin(x=syp.pipiens.group$number_positive_pools,
                                 m=syp.pipiens.group$size_of_pools,
                                 n=syp.pipiens.group$number_of_pools,
                                 pt.method='mir')$p)))      
      

# syp.pipiens.group = syp.pipiens[,
#                                 .(pipi_mosquitoes_tested = sum(size_of_pools),
#                                   pipi_pools_tested = sum(number_of_pools),
#                                   pipi_pools_tested_positive = sum(number_positive_pools),
#                                   pipi_prev = ifelse(sum(number_positive_pools) == sum(number_of_pools),
#                                                      sum(number_positive_pools)/sum(size_of_pools),
#                                                      ifelse(sum(number_positive_pools) == 0,
#                                                             0,
#                                                             pooledBin(x=number_positive_pools,m=size_of_pools,n=number_of_pools,pt.method='mir')$p))),
#                                 by=list(calculated_subcounty,study_week)]


# Abundance

maindata.start = expand.grid(calculated_subcounty = unique(syabund$calculated_subcounty),study_week=1:831)

symaster = merge(maindata.start,syabund,by=c('calculated_subcounty','study_week'),all.x = TRUE)

symaster = merge(symaster,syp.tarsalis.group,by=c('calculated_subcounty','study_week'),all.x = TRUE)

symaster = merge(symaster,syp.pipiens.group,by=c('calculated_subcounty','study_week'),all.x = TRUE)

#replacing NAs with 0

symaster[is.na(symaster)] = 0


d1 = symaster
d1 = data.table(d1)

d2 = d1[,.(avg_tmin=mean(min_temp),
           avg_tmean=mean(mean_temp),
           avg_tmax=mean(max_temp),
           sd_tmin=sd(min_temp),
           sd_tmean=sd(mean_temp),
           sd_tmax=sd(max_temp)),
        by=.(calculated_subcounty,week)]

d3 = merge(d1,d2,by=c('calculated_subcounty','week'))
d3 = d3[order(d3$calculated_subcounty,d3$study_week)]

d3$dev_tmin = d3$min_temp-d3$avg_tmin
d3$dev_tmean = d3$mean_temp-d3$avg_tmean
d3$dev_tmax = d3$max_temp-d3$avg_tmax

d3$dev_tmin_in_sd = d3$dev_tmin/d3$sd_tmin
d3$dev_tmean_in_sd = d3$dev_tmean/d3$sd_tmean
d3$dev_tmax_in_sd = d3$dev_tmax/d3$sd_tmax

#creating a variable called 'temp_peak', which will be 1 in case any of the deviations in sd > 1, and 0 otherwise
d3$temp_peak = ifelse(d3$dev_tmin_in_sd > 1 | d3$dev_tmean_in_sd > 1 | d3$dev_tmax_in_sd > 1, 1,0)

mydata=d3
                  
saveRDS(mydata,'~/Downloads/DART/Project/DATA/mydata.rds')


