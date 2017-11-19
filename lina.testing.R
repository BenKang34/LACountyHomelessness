library(shiny)
library(ggplot2)
library(tidycensus)
library(tidyverse)
library(leaflet)

###The following code read in datafiles and create new measures and extra features

###Step 1: Read in the data files

crime<-read.csv("data/crime_w_CTs20171102134814.csv")
calls311<-read.csv("data/311_calls_w_CTs20171102134828.csv")
hc2016<-read.csv("data/HC2016_Total_Counts_by_Census_Tract_LA_CoC_07132016.csv")
hc2017_ct<-read.csv("data/homeless-count-2017-results-by-census-tract.csv")
hc2017_com<-read.csv("data/homeless-count-2017-results-by-census-tract_by_community.csv")
shelter<-read.csv("data/shelters_w_CTs20171102134808.csv")
###the following la census geo data file was obtained through tidycensus package with an API key
lapop<-readRDS("data/lapop.rds")
lapop$ct<-as.integer(lapop$ct) ##convert ct (census tract) variable to integer, so it can be matched to the other datasets


###Step 2: select the homeless count variables from hc2016 and hc2017,
#### 
###new count measures created: 1. total unaccompanied minor sheltered (<18 year old): adding up total unaccompanies minor in different types of shelters
####2. total single youth sheltered(>=18, <24): adding up total single youth in different types of shelters
### 
###The count measures selected: totPeople (total homeless), totUnsheltPeople(total unsheltered peple)
##totsheltPeople (total sheltered people), totStreetSingleAdult, totStreetFamilyMM, totYouthFamilyHH, 
###totUnaccMinor_sheltered, totSingleYouth_sheltered

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

###Step 3: get the count of crime in 2016-2017 and count of 311 call in 2017 by tract
crime_count<-crime%>%
  group_by(CT10) %>%
  summarize(count_crime=n())

calls311_count<-calls311 %>%
  group_by(CT10) %>%
  summarize(count_311calls=n())


##Merge hc2017_ct_subset and the GIOID information from lapop
hc2017_ct_subset<-full_join(x=hc2017_ct_subset,y=lapop[c(1, 7)], by=c("tract" = "ct"))
hc2016_ct_subset<-full_join(x=hc2016_ct_subset,y=lapop[c(1, 7)], by=c("censusTract" = "ct"))
crime_count <- full_join(x=crime_count, y = lapop[c(1, 7)], by=c("CT10" = "ct"))
calls311_count = full_join(x = calls311_count, y = lapop[c(1, 7)], by = c("CT10" = "ct"))


###The following code merge the data with the geospatial dataframe, and creating merged
### geospatial dataframe objects, which can be used to create polygons in leaflet

library(tigris)
library(acs)


# use county names in the tigris package but to grab the spatial data (tigris)
tracts<-tracts(state="CA", county="Los Angeles", cb = TRUE)
##Merge the hc, crime, 311 data with tracts geo data, create a spatial poygons Data frame
hc2017_merged<-geo_join(tracts, hc2017_ct_subset, "GEOID", "GEOID")
hc2016_merged<-geo_join(tracts, hc2016_ct_subset, "GEOID", "GEOID")
crime_merged<-geo_join(tracts, crime_count, "GEOID", "GEOID")
calls311_merged<-geo_join(tracts, calls311_count, "GEOID", "GEOID")


###Make a map of homeless count

pal1 <- colorNumeric(
  palette = "YlOrRd",
  domain = hc2017_ct_subset$totUnsheltPeople
)

map1<-leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = hc2017_merged, 
              fillColor = ~pal1(totUnsheltPeople), 
              color = "#b2aeae", # you need to use hex colors
              fillOpacity = 0.7, 
              weight = 1, 
              smoothFactor = 0.2) %>%
  addLegend(pal = pal1, 
            values = hc2017_merged$totUnsheltPeople, 
            position = "bottomright", 
            title = "Total Unsheltered People"
            #labFormat = labelFormat(suffix = "")
            ) 
map1





###Make a map of 311 calls
pal2 <- colorNumeric(
  palette = "YlOrRd",
  domain = calls311_merged$count_311calls
)

map2<-leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = calls311_merged, 
              fillColor = ~pal2(count_311calls), 
              color = "#b2aeae", # you need to use hex colors
              fillOpacity = 0.7, 
              weight = 1, 
              smoothFactor = 0.2) %>%
  addLegend(pal = pal2, 
            values = calls311_merged$count_311calls, 
            position = "bottomright", 
            title = "Total 311 calls"
           # labFormat = labelFormat(suffix = "")
            ) 
map2

##Make a map of crime count



###Make a map of 311 calls
pal3 <- colorNumeric(
  palette = "YlOrRd",
  domain = crime_merged$count_crime)

map3<-leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = crime_merged, 
              fillColor = ~pal3(count_crime), 
              color = "#b2aeae", # you need to use hex colors
              fillOpacity = 0.7, 
              weight = 1, 
              smoothFactor = 0.2 ) %>%
  addLegend(pal = pal2, 
            values = crime_merged$count_crime, 
            position = "bottomright", 
            title = "Total crime count 2016-2017"
            # labFormat = labelFormat(suffix = "")
  ) 
map3



#runApp("./dashboard")


