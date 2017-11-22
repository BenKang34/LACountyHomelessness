library(shiny)
library(ggplot2)
library(tidycensus)
library(tidyverse)
library(maptools)
#library(eply)
### The following code read in datafiles
### and create new measures and extra features

### Step 1: Read in the data files

crime<-read.csv("data/crime_w_CTs20171102134814.csv")
calls311<-read.csv("data/311_calls_w_CTs20171102134828.csv")
hc2016<-read.csv("data/HC2016_Total_Counts_by_Census_Tract_LA_CoC_07132016.csv")
hc2017_ct<-read.csv("data/homeless-count-2017-results-by-census-tract.csv")
hc2017_com<-read.csv("data/homeless-count-2017-results-by-census-tract_by_community.csv")
shelter<-read.csv("data/shelters_w_CTs20171102134808.csv")
###the following la census geo data file was obtained through
###tidycensus package with an API key
lapop<-readRDS("data/lapop.rds")
## convert ct (census tract) variable to integer,
## so it can be matched to the other datasets
lapop$ct<-as.integer(lapop$ct) 


### Step 2: select the homeless count variables from hc2016 and hc2017,
### 
### New count measures created: 
### 1. total unaccompanied minor sheltered (<18 year old): 
###    adding up total unaccompanies minor in different types of shelters
### 2. total single youth sheltered(>=18, <24):
###    adding up total single youth in different types of shelters
### 
### The count measures selected: 
###  1) totPeople (total homeless)
###  2) totUnsheltPeople(total unsheltered peple)
###  3) totsheltPeople (total sheltered people)
###  4) totStreetSingleAdult
###  5) totStreetFamilyMM
###  6) totYouthFamilyHH, 
###  7) totUnaccMinor_sheltered
###  8) totSingleYouth_sheltered

hc2017_ct_subset<-
  hc2017_ct %>% mutate(totUnAccMinor_sheltered=
                         totESYouthUnaccYouth+totTHYouthUnaccYouth+totSHYouthUnaccYouth,
                       totSingleYouth_sheltered=
                         totESYouthSingYouth+totTHYouthSingYouth+totSHYouthSingYouth) %>% 
  dplyr::select(c(1:3, 5,73,68,72,18,20,46,74,75))

hc2017_ct_subset <- hc2017_ct_subset %>%
  mutate(LNtotSheltPeople = ifelse(is.na(totSheltPeople) | totSheltPeople == 0,
                                     0,log10(totSheltPeople))) %>%
  mutate(LNtotUnsheltPeople = ifelse(is.na(totUnsheltPeople) | totUnsheltPeople == 0,
                                     0,log10(totUnsheltPeople)))

hc2017_com_subset<-hc2017_com %>% mutate(totUnAccMinor_sheltered=
                                           totESYouthUnaccYouth+totTHYouthUnaccYouth+totSHYouthUnaccYouth,
                                         totSingleYouth_sheltered=
                                           totESYouthSingYouth+totTHYouthSingYouth+totSHYouthSingYouth) %>%
  dplyr::select(c(1, 66, 61,  65, 11, 13, 39, 67, 68))


###select the same set of variables from hc2016 dataset
hc2016_ct_subset<-
  hc2016 %>% dplyr::select(c(1:4, 56, 51,55, 13, 15, 28, 27, 26))

###Step 3: get the count of crime in 2016-2017
###        and count of 311 call in 2017 by tract
crime_count<-crime%>%
  group_by(CT10) %>%
  summarize(count_crime=n())

calls311_count<-calls311 %>%
  group_by(CT10) %>%
  summarize(count_311calls=n())

dataGEOID_CT = data.frame(GEOID = lapop$GEOID, ct = lapop$ct)

##Merge hc2017_ct_subset and the GEOID information from lapop
hc2017_ct_subset<-full_join(x=hc2017_ct_subset,y=dataGEOID_CT, by=c("tract" = "ct"))
hc2016_ct_subset<-full_join(x=hc2016_ct_subset,y=dataGEOID_CT, by=c("censusTract" = "ct"))
crime_count <- full_join(x=crime_count, y = dataGEOID_CT, by=c("CT10" = "ct"))
calls311_count = full_join(x = calls311_count, y = dataGEOID_CT, by = c("CT10" = "ct"))


###Remove the datasets that are not needed to save memory


### The following code merge the data with the geospatial dataframe, 
### and creating merged geospatial dataframe objects, 
### which can be used to create polygons in leaflet

library(tigris)
library(acs)


# use county names in the tigris package but to grab the spatial data (tigris)
tracts<-tracts(state="CA", county="Los Angeles", cb = TRUE)
## Merge the hc, crime, 311 data with tracts geo data,
## and create a Spatial Polygons Data frame
hc2017_merged<-geo_join(tracts, hc2017_ct_subset, "GEOID", "GEOID")
hc2016_merged<-geo_join(tracts, hc2016_ct_subset, "GEOID", "GEOID")
crime_merged<-geo_join(tracts, crime_count, "GEOID", "GEOID")
calls311_merged<-geo_join(tracts, calls311_count, "GEOID", "GEOID")

#hc2017_merged<-geo_join(hc2017_merged, crime_merged, "GEOID", "GEOID")
#hc2017_merged<-geo_join(hc2017_merged, calls311_merged, "GEOID", "GEOID")

hc2017_ct_subset.comm <- aggregate(hc2017_ct_subset[5:14], list(Community = hc2017_ct_subset$Community_Name), sum)
hc2017_ct_subset.city <- aggregate(hc2017_ct_subset[5:14], list(City = hc2017_ct_subset$City), sum)

hc2017_merged.Community <- unionSpatialPolygons(hc2017_merged, hc2017_merged@data$Community_Name)
hc2017_merged.City <- unionSpatialPolygons(hc2017_merged, hc2017_merged@data$City)

row.names(hc2017_ct_subset.comm) <- as.character(hc2017_ct_subset.comm$Community)
row.names(hc2017_ct_subset.city) <- as.character(hc2017_ct_subset.city$City)
hc2017_merged.Community <- SpatialPolygonsDataFrame(hc2017_merged.Community, hc2017_ct_subset.comm)
hc2017_merged.City <- SpatialPolygonsDataFrame(hc2017_merged.City, hc2017_ct_subset.city)

###get the names of all homeless count measures
vars<-colnames(hc2017_ct_subset[5:14])
titles<-c("Total Homeless People", 
          "Total Unsheltered People", 
          "Total Sheltered People",
          "Total Sheltered People(Log10 Scale)",
          "Total Unsheltered People(Log10 Scale)",
          "Total Street Single Adult",
          "Total Street Family Members",
          "Total Youth Family Households",
          "Total Unaccompanied Kids in Shelters",
          "Total Single Youth in Shelters")

###remove the datasets that are not needed to save memory
rm(hc2016,hc2016_ct_subset,hc2017_com, hc2017_ct, hc2017_ct_subset,
   lapop, dataGEOID_CT)

### manipulate the crime data for the map,create a [crime type]column
library(stringr)
CRIME_TYPE <- function(x){
  CRIME_TYPE <- numeric(length(x))
  CRIME_TYPE[str_detect(x,"ASSAULT")]<-"ASSAULT"
  CRIME_TYPE[str_detect(x,"ROBBERY")]<-"ROBBERY"
  CRIME_TYPE[str_detect(x,"THEFT")]<-"THEFT"
  CRIME_TYPE[str_detect(x,"RAPE") | str_detect(x,"SEX")]<-"SEXUAL_CRIME"
  CRIME_TYPE
}


library(dplyr)
crime=crime %>%
  mutate(CRIME.TYPE=CRIME_TYPE(CRIME.CODE.DESCRIPTION))

runApp("./dashboard")


