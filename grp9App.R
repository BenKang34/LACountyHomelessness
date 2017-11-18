library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
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
lapop$ct<-as.integer(lapop$ct)
###Step 2: select the variables of interest from hc2016 and hc2017,
####create new density measures: total unaccompanied minor sheltered (<18 year old)
####total single youth sheltered(>=18, <24)
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

hc2016_ct_subset<-
  hc2016 %>% dplyr::select(c(1:4, 56, 51,55, 13, 15, 28, 27, 26))

###Step 3: get the count of crime and count of 311 call by tract
crime_count<-crime%>%
  group_by(CT10) %>%
  summarize(count_crime=n())

calls311_count<-calls311 %>%
  group_by(CT10) %>%
  summarize(count_311calls=n())


##Merge hc2017_ct_subset and the geo information from lapop
hc2017_ct_subset<-full_join(x=lapop, y=hc2017_ct_subset, by=c("ct" = "tract"))
crime_count <- left_join(x=crime_count, y = lapop, by=c("CT10" = "ct"))
calls311 = left_join(x = calls311, y = lapop, by = c("CT10" = "ct"))



runApp("./dashboard")


