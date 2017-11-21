library(shinydashboard)
library(leaflet)
library(tidycensus)
library(tidyverse)
library(sf)

###Make a map of homeless count




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

function(input, output) {

  #data = reactive({
  #})
  
  #map
  output$map = renderLeaflet({
    ###create four maps
    hcmapTool(hc2017_merged,"totUnsheltPeople")
    #hcmapTool(hc2017_merged,"totSheltPeople")
    #hcmapTool(hc2017_merged,"totStreetSingAdult")
    #hcmapTool(hc2017_merged,"totStreetFamMem")
  })
  output$map_crime = renderLeaflet({
    map_crime= filter(crime,TIME.OCCURRED>=input$range[1] &TIME.OCCURRED<=input$range[2] )%>%
      leaflet()%>%
      addTiles%>%
      addMarkers(~LONGITUDE, ~LATITUDE)
    map_crime
  })
}


