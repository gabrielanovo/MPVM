# MPVM

## 1. Data organization

Read the 5 organization.R codes in the following order to obtain the final dataset used for the analysis

### 1.1. data_organization_mosquito_collection.R

- read in the following 3 mosquito collection datasets
  - **sacyolo_mosquito_collections_2006to2011.csv**
    - 47,350 observations
    - 274 variables
  - **sacyolo_mosquito_collections_2012to2017.csv** 
    - 132,511 observations
	  - 316 variables
  - **sacyolo_mosquito_collections_2018to2021.csv**
	  - 30,740 observations
	  - 465 variables
- merge the 3 datasets above
- create `year`, `month` and `week` variables
- ignore the 53rd week of leap years
- create the `study_week` variable
- overall dataset created in this code is called `sacyolo_mosquito_collections_2006to2021`
  - 132,511 observations
  - 58 total variables
- group the data by date (`year` and `week`) and location (`calculated_subcounty`)
- final R dataset with the grouped data is called `collection_data_epiweek`
  - 10,110 observations
  - 7 variables

### 1.2. data_organization_temperature.R
- reads in the following temperature dataset
  - `temperature_data_by_county_subdivision`
    - 198,628 observations
    - 18 variables
- create `year`, `month` and `week` variables
- merge the data by date (`year` and `week`) and location (`calculated_subcounty`)
- final R dataset of this code is called `temperature_data_epiweek`
    - 28,832 observations
    - 6 variables

### 1.3. data_organization_abundance.R 
(abundance dataset = collection dataset + temperature dataset)

- read in the 2 codes above 
- merge the `collection_data_epiweek` and `temperature_data_epiweek` datasets by date (`week` and `year`) and location (`calculated_subcounty`)
- create a function to obtain the `date` variable that we lost in the merging process
	- apply the function to the data
	- recreate `study_week` and `month` variables based on our new `date` variable
	- reorder the columns and sort the data by `calculated_subcounty` and `study_week`
	- final R dataset from this code is called `collection_temperature_epiweek`
    - 9,301 observations
    - 14 variables
	- export the data as **syabund.rds**

### 1.4. data_organization_pools.R
- read in the following dataset
  - `sac-yolo_mosquito_pool_test_result`
    - 327,719 observations
    - 32 variables
- create `year`, `month` and `week` variables
- ignore the 53rd week of leap years
- create the `study_week` variable
- restrict the dataset for pools targeting WNV only, and including only female *C. pipiens* and *C. tarsalis*
- code positive pools as 1 and negative as 0
- arrange the data by `calculated_subcounty` and `study_week`
- final R dataset from this code is called `sy_pools_wnv`
  - 101,729 observations
  - 11 variables
- export the data as **sypools.rds**


### 1.5. data_organization_final_dataset.R 
(final dataset = abundance dataset + pools dataset)

- read in the following datasets:
    - `syabund`
    - `sypools`
- subset the data by species (*C. tarsalis* or *C. pipiens*)
- group each subset by `calculated_subcounty` and `study_week`
- create a new variable for infection prevalence (`pipi_prev` and `tars_prev`)
- merge the abundance dataset with both subsets 
- calculate average values for min, mean and max temperatures by subcounty by week
- calculate values for temperature deviation and deviation in standard deviation by subcounty by week
- create a variable called `temp_peak` , which will be 1 in case any of the deviations-in-sd is greater than 1, and 0 otherwise
- final R dataset from this code is called `mydata`
  - 13,336 observations
  - 35 variables
- export the data as **mydata.rds**
		



