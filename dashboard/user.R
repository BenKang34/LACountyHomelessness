library(shiny)
#install.packages('DT')
#setwd('./Desktop/lahomeless')
runApp('./D2') #barchart & table
runApp('./D1') #map








#-----------below are trials & errors--------------
library(ggplot2)
library(dplyr)
data = read.csv('./D1/mdata.csv')
names(data)

data %>%
  mutate_(f = 'totPeople',g='Tract')%>%
  group_by(g)%>%
  select(c(f,g,long)) %>%
  summarise(f=mean(f)) %>%
  arrange(desc(f)) %>%
  slice(1:5)%>%
  ggplot(aes(x = factor(g),y = f)) + geom_bar(stat='identity')+coord_flip()

d2=data %>%
  mutate_(cat = 'totUnsheltPeople',geo='Tract')%>%
  select(cat,geo,long,lat) %>%
  mutate(long = as.numeric(long),lat = as.numeric(lat))%>%
  slice(1:100)
