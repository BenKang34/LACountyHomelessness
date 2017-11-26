library(shiny)
library(ggplot2)
library(tidycensus)
library(tidyverse)
library(maptools)
library(stringr)
#library(eply)
### The following code read in datafiles
### and create new measures and extra features

### Step 1: Read in the data files

crime<-read.csv("data/crime_w_CTs20171102134814.csv")
calls311<-read.csv("data/311_calls_w_CTs20171102134828.csv")
hc2016<-read.csv("data/HC2016_Total_Counts_by_Census_Tract_LA_CoC_07132016.csv")
hc2017_ct<-read.csv("data/homeless-count-2017-results-by-census-tract.csv") #, fileEncoding = "UTF-8")
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

hc2017_com_subset<-hc2017_com %>% mutate(totUnAccMinor_sheltered=
                                           totESYouthUnaccYouth+totTHYouthUnaccYouth+totSHYouthUnaccYouth,
                                         totSingleYouth_sheltered=
                                           totESYouthSingYouth+totTHYouthSingYouth+totSHYouthSingYouth) %>%
  dplyr::select(c(1, 66, 61,  65, 11, 13, 39, 67, 68))


###select the same set of variables from hc2016 dataset
hc2016_ct_subset<-
  hc2016 %>% dplyr::select(c(1:4, 56, 51,55, 13, 15, 28, 27, 26))


hc2017_ct_subset <- left_join(x = hc2017_ct_subset,
                              y = hc2016_ct_subset[c(1,6)],
                              by=c("tract"="censusTract"))

colnames(hc2017_ct_subset)[6] <- "totUnsheltPeople"
colnames(hc2017_ct_subset)[13] <- "totUnsheltPeople.2016"


###Step 3: Get counts of 
###        1. crime in 2016-2017  2. 311 call in 2017  3. Shelters
###        by tract
crime_count<-crime%>%
  group_by(CT10) %>%
  summarize(count_crime=n())

calls311_count<-calls311 %>%
  group_by(CT10) %>%
  summarize(count_311calls=n())

shelter_count<-shelter%>%
  group_by(CT10) %>%
  summarize(count_shelter=n())

hc2017_ct_subset <- left_join(x = hc2017_ct_subset,
                              y = crime_count[c(1,2)],
                              by=c("tract"="CT10"))
hc2017_ct_subset <- left_join(x = hc2017_ct_subset,
                              y = calls311_count[c(1,2)],
                              by=c("tract"="CT10"))
hc2017_ct_subset <- left_join(x = hc2017_ct_subset,
                              y = shelter_count[c(1,2)],
                              by=c("tract"="CT10"))

dataGEOID_CT = data.frame(GEOID = lapop$GEOID, tract = lapop$ct)

##Merge hc2017_ct_subset and the GEOID information from lapop
hc2017_ct_subset<-full_join(x=dataGEOID_CT,y=hc2017_ct_subset, by=c("tract" = "tract"))
hc2016_ct_subset<-full_join(x=dataGEOID_CT,y=hc2016_ct_subset, by=c("tract" = "censusTract"))
crime_count <- full_join(x=crime_count, y = dataGEOID_CT, by=c("CT10" = "tract"))
calls311_count = full_join(x = calls311_count, y = dataGEOID_CT, by = c("CT10" = "tract"))

CommunityInLACitylist <- hc2017_ct_subset %>%
  select("City", "Community_Name") %>%
  filter(City == "Los Angeles") 
CommunityInLACitylist <- as.factor(CommunityInLACitylist$Community_Name)
  

hc2017_ct_subset.comm <- aggregate(hc2017_ct_subset[6:17], list(Community = hc2017_ct_subset$Community_Name), sum, na.rm=T)
hc2017_ct_subset.city <- aggregate(hc2017_ct_subset[6:17], list(City = hc2017_ct_subset$City), sum, na.rm=T)

## Create Measures
hc2017_ct_subset <- hc2017_ct_subset %>% 
  mutate(totUnsheltChanges = totUnsheltPeople - totUnsheltPeople.2016) %>% 
  mutate(LNtotSheltPeople = ifelse(totSheltPeople > 0, log10(totSheltPeople), NA)) %>%
  mutate(LNtotUnsheltPeople = ifelse(totUnsheltPeople > 0, log10(totUnsheltPeople), NA)) %>%
  mutate(CrimeUnsheltRatio = ifelse(totUnsheltPeople==0,
                                    count_crime/totUnsheltPeople,NA)) %>%
  mutate(CallsUnsheltRatio = ifelse(totUnsheltPeople==0,
                                    count_311calls/totUnsheltPeople,NA)) %>%
  mutate(TotPeopleSheltersRatio = ifelse(count_shelter==0,
                                         totPeople,
                                         totPeople/count_shelter))


hc2017_ct_subset.comm <- hc2017_ct_subset.comm %>% 
  mutate(totUnsheltChanges = totUnsheltPeople - totUnsheltPeople.2016) %>% 
  mutate(LNtotSheltPeople = ifelse(totSheltPeople > 0, log10(totSheltPeople), NA)) %>%
  mutate(LNtotUnsheltPeople = ifelse(totUnsheltPeople > 0, log10(totUnsheltPeople), NA)) %>%
  mutate(CrimeUnsheltRatio = ifelse(totUnsheltPeople > 10 & Community %in% CommunityInLACitylist,
                                    count_crime/totUnsheltPeople,NA)) %>%
  mutate(CallsUnsheltRatio = ifelse(totUnsheltPeople > 10 & Community %in% CommunityInLACitylist,
                                    count_311calls/totUnsheltPeople,NA)) %>%
  mutate(TotPeopleSheltersRatio = ifelse(totPeople > 10,
                                         ifelse(count_shelter==0,
                                                totPeople,
                                                totPeople/count_shelter),NA))

hc2017_ct_subset.city <- hc2017_ct_subset.city %>% 
  mutate(totUnsheltChanges = totUnsheltPeople - totUnsheltPeople.2016) %>% 
  mutate(LNtotSheltPeople = ifelse(totSheltPeople > 0, log10(totSheltPeople), NA)) %>%
  mutate(LNtotUnsheltPeople = ifelse(totUnsheltPeople > 0, log10(totUnsheltPeople), NA)) %>%
  mutate(CrimeUnsheltRatio = ifelse(totUnsheltPeople > 20 & City == "Los Angeles",
                                    count_crime/totUnsheltPeople, NA)) %>%
  mutate(CallsUnsheltRatio = ifelse(totUnsheltPeople > 20 & City == "Los Angeles",
                                    count_311calls/totUnsheltPeople, NA)) %>%
  mutate(TotPeopleSheltersRatio = ifelse(totPeople > 20,
                                         ifelse(count_shelter==0,
                                                totPeople,
                                                totPeople/count_shelter),NA))

## Get Rankings of potential locations for shelters
## Measures that are considered to rank the geographics
## 1. Crime/UnsheltPeople 0.5
## 2. 311calls/UnsheltPeople 0.3
## 3. Shelters/TotalPeople 0.2
w1 = 0.1
w2 = 0.2
w3 = 0.7

maxCrimeToUnsheltpeople <- max(hc2017_ct_subset$CrimeUnsheltRatio, na.rm = T)
maxCallsToUnshltpeople <- max(hc2017_ct_subset$CallsUnsheltRatio, na.rm = T)
maxSheltersToTotalpeople <- max(hc2017_ct_subset$TotPeopleSheltersRatio, na.rm = T)
  
hc2017_ct_subset <- hc2017_ct_subset %>%
  mutate(RankShelterLocation = w1*(CrimeUnsheltRatio/maxCrimeToUnsheltpeople)^2+
           w2*(CallsUnsheltRatio/maxCallsToUnshltpeople)^2+
           w3*(TotPeopleSheltersRatio/maxSheltersToTotalpeople)^2)

maxCrimeToUnsheltpeople <- max(hc2017_ct_subset.comm$CrimeUnsheltRatio, na.rm = T)
maxCallsToUnshltpeople <- max(hc2017_ct_subset.comm$CallsUnsheltRatio, na.rm = T)
maxSheltersToTotalpeople <- max(hc2017_ct_subset.comm$TotPeopleSheltersRatio, na.rm = T)

hc2017_ct_subset.comm <- hc2017_ct_subset.comm %>%
  mutate(RankShelterLocation = w1*(CrimeUnsheltRatio/maxCrimeToUnsheltpeople)^2+
           w2*(CallsUnsheltRatio/maxCallsToUnshltpeople)^2+
           w3*(TotPeopleSheltersRatio/maxSheltersToTotalpeople)^2)

maxCrimeToUnsheltpeople <- max(hc2017_ct_subset.city$CrimeUnsheltRatio, na.rm = T)
maxCallsToUnshltpeople <- max(hc2017_ct_subset.city$CallsUnsheltRatio, na.rm = T)
maxSheltersToTotalpeople <- max(hc2017_ct_subset.city$TotPeopleSheltersRatio, na.rm = T)

hc2017_ct_subset.city <- hc2017_ct_subset.city %>%
  mutate(RankShelterLocation = w1*(CrimeUnsheltRatio/maxCrimeToUnsheltpeople)^2+
           w2*(CallsUnsheltRatio/maxCallsToUnshltpeople)^2+
           w3*(TotPeopleSheltersRatio/maxSheltersToTotalpeople)^2)


###Remove the datasets that are not needed to save memory


### The following code merge the data with the geospatial dataframe, 
### and creating merged geospatial dataframe objects, 
### which can be used to create polygons in leaflet

library(tigris)
#library(acs)


# use county names in the tigris package but to grab the spatial data (tigris)
#tracts<-tracts(state="CA", county="Los Angeles", cb = TRUE)
tracts<-readRDS("data/LASpatialData.rda")
## Merge the hc, crime, 311 data with tracts geo data,
## and create a Spatial Polygons Data frame
hc2017_merged<-geo_join(tracts, hc2017_ct_subset, "GEOID", "GEOID")
hc2016_merged<-geo_join(tracts, hc2016_ct_subset, "GEOID", "GEOID")
crime_merged<-geo_join(tracts, crime_count, "GEOID", "GEOID")
calls311_merged<-geo_join(tracts, calls311_count, "GEOID", "GEOID")

#hc2017_merged<-geo_join(hc2017_merged, crime_merged, "GEOID", "GEOID")
#hc2017_merged<-geo_join(hc2017_merged, calls311_merged, "GEOID", "GEOID")

hc2017_merged.Community <- unionSpatialPolygons(hc2017_merged, hc2017_merged@data$Community_Name)
hc2017_merged.City <- unionSpatialPolygons(hc2017_merged, hc2017_merged@data$City)

row.names(hc2017_ct_subset.comm) <- as.character(hc2017_ct_subset.comm$Community)
row.names(hc2017_ct_subset.city) <- as.character(hc2017_ct_subset.city$City)
hc2017_merged.Community <- SpatialPolygonsDataFrame(hc2017_merged.Community, hc2017_ct_subset.comm)
hc2017_merged.City <- SpatialPolygonsDataFrame(hc2017_merged.City, hc2017_ct_subset.city)
#
object.size(hc2017_merged)
#hc2017_merged <- rmapshaper::ms_simplify(hc2017_merged)
object.size(hc2017_merged)
###get the names of all homeless count measures
vars<-colnames(hc2017_ct_subset[6:24])
titles<-c("Total Homeless People", 
          "Total Unsheltered People", 
          "Total Sheltered People",
          "Total Street Single Adult",
          "Total Street Family Members",
          "Total Youth Family Households",
          "Total Unaccompanied Kids in Shelters",
          "Total Single Youth in Shelters",
          "Total Unsheltered People(2016)",
          "Crime Counts",
          "311 Calls Counts",
          "Shelter Counts",
          "Change of Total Unsheltered People",
          "Total Sheltered People(Log10 Scale)",
          "Total Unsheltered People(Log10 Scale)",
          "Crimes to Unsheltered People Ratio",
          "311 Calls to Unsheltered People Ratio",
          "Total Homeless People to Shelters Ratio",
          "Shelters to be located")

###remove the datasets that are not needed to save memory
#rm(hc2016,hc2016_ct_subset,hc2017_com, hc2017_ct, hc2017_ct_subset,
#   lapop, dataGEOID_CT)

### manipulate the crime data for the map,create a [crime type]column
CRIME_TYPE <- function(x){
  CRIME_TYPE <- numeric(length(x))
  CRIME_TYPE[str_detect(x,"ASSAULT")]<-"ASSAULT"
  CRIME_TYPE[str_detect(x,"ROBBERY")]<-"ROBBERY"
  CRIME_TYPE[str_detect(x,"THEFT")]<-"THEFT"
  CRIME_TYPE[str_detect(x,"RAPE") | str_detect(x,"SEX")]<-"SEXUAL_CRIME"
  CRIME_TYPE
}

crime=crime %>%
  mutate(CRIME.TYPE=CRIME_TYPE(CRIME.CODE.DESCRIPTION))

runApp("./dashboard")


