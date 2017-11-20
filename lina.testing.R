library(shiny)
library(ggplot2)
library(tidycensus)
library(tidyverse)
library(leaflet)
#library(eply)
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


###Remove the datasets that are not needed to save memory


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

#hc2017_merged<-geo_join(hc2017_merged, crime_merged, "GEOID", "GEOID")
#hc2017_merged<-geo_join(hc2017_merged, calls311_merged, "GEOID", "GEOID")


###Make a map of homeless count

###get the names of all homeless count measures
vars<-colnames(hc2017_ct_subset[5:12])
titles<-c("Total homeless", 
          "Total unsheltered people", 
          "Total Sheltered people",
          "Total Street Single Adult",
          "Total Street Family Members",
          "Total Youth Family Households",
          "Total Unaccompanied Kids in Shelters",
          "Total Single Youth in Shelters")


###a function that takes in a homeless count measure, 
###and return a color pallette based on the data
palfun<-function(hc){
  pal<-colorNumeric(
    palette = "YlOrRd",
    domain = hc2017_merged@data[hc]
  )
}

###a function that take in a dataset and homeless count measure, and create a map
###including both homeless count, crime count and shelters

hcmapTool<-function(data,hc){
  ##creat a palette for the hc variable  
  pal=palfun(hc)
  leaflet() %>%
    ## Base Groups
    addProviderTiles("CartoDB.Positron", group="County Map") %>% 
    addPolygons(data = data, 
                fillColor = ~pal(data@data[hc]), 
                color = "#b2aeae", # you need to use hex colors
                fillOpacity = 0.7, 
                weight = 1, 
                smoothFactor = 0.2,
                label=~as.character(unlist(data@data[hc])),
                highlightOptions=highlightOptions(color="black", 
                                                  weight=2,
                                                  bringToFront=TRUE),
                group="Homeless Density")%>%
    addLegend(pal = pal, 
              values =unlist(data@data[hc]), 
              position = "bottomright", 
              title = titles[match(hc, vars)] #the the index of hc, and then get the title
              #labFormat = labelFormat(suffix = "")
              #  group="Homeless Density Legend"
    ) %>%
    addMarkers(data=crime, ~LONGITUDE, ~LATITUDE,
               label="crime",
               labelOptions=labelOptions(style=list("color"="red")),
               clusterOptions=markerClusterOptions(),
               group="Crime Count 2016~2017") %>%
    addMarkers(data=shelter, ~LONGITUDE, ~LATITUDE,
               group="Shelters") %>%
    addLayersControl(
      baseGroups="County Map",
      overlayGroups=c("Homeless Density", 
                      "Crime Count 2016~2017",
                      "Shelters"),
      options=layersControlOptions(collapsed=FALSE)
    )
}

###remove the datasets that are not needed to save memory
rm(hc2016,hc2016_ct_subset,hc2017_com, hc2017_ct, hc2017_ct_subset, lapop)

###create four maps
hcmapTool(hc2017_merged,"totUnsheltPeople")
hcmapTool(hc2017_merged,"totSheltPeople")
hcmapTool(hc2017_merged,"totStreetSingAdult")
hcmapTool(hc2017_merged,"totStreetFamMem")


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


