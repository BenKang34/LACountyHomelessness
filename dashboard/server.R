library(shinydashboard)
library(leaflet)
library(tidycensus)
library(tidyverse)
library(sf)

###Make a map of homeless count




###a function that takes in a homeless count measure, 
###and return a color pallette based on the data
palfunc<-function(LAmapdata, hc){
  pal<-colorNumeric(
    palette = "YlOrRd",
    domain = LAmapdata@data[hc]
  )
}

###a function that take in a dataset and homeless count measure, and create a map
###including both homeless count, crime count and shelters

hcmapTool<-function(LAmapdata,geolevel,hc){
  ##creat a palette for the hc variable  
  pal=palfunc(LAmapdata,hc)
  leaflet() %>%
    ## Base Groups
    addProviderTiles("CartoDB.Positron", group="County Map") %>% 
    addPolygons(data = LAmapdata, 
                fillColor = ~pal(LAmapdata@data[hc]), 
                color = "#b2aeae", # you need to use hex colors
                fillOpacity = 0.7, 
                weight = 1, 
                smoothFactor = 0.2,
                label=~paste(unlist(LAmapdata@data[geolevel]),
                             unlist(LAmapdata@data[ifelse(str_detect(hc,"LN"),
                                                     substr(hc, start = 3, stop = str_length(hc)),
                                                     hc)])),
                highlightOptions=highlightOptions(color="black", 
                                                  weight=2,
                                                  bringToFront=TRUE),
                group="Homeless Density")%>%
    addLegend(pal = pal, 
              values =unlist(LAmapdata@data[hc]), 
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
      #baseGroups="County Map",
      overlayGroups=c("Homeless Density", 
                      "Crime Count 2016~2017",
                      "Shelters"),
      options=layersControlOptions(collapsed=FALSE)
    ) %>%
    hideGroup(c("Crime Count 2016~2017", "Shelters"))
  
}

function(input, output) {

  
  ### Dashboard Page
  output$map = renderLeaflet({
    inputDataset = switch(input$geolevel,
                          'CensusTract' = hc2017_merged,
                          'Community' = hc2017_merged.Community,
                          'City' = hc2017_merged.City
                          )
    inputGeolevel = switch(input$geolevel,
                          'CensusTract' = "tract",
                          'Community' = "Community",
                          'City' = "City"
                          )
    category_HC = switch(input$catHC,
                         "Total Homeless People" = "totPeople", 
                         "Total Unsheltered People" = "totUnsheltPeople",
                         "Total Sheltered People(Log10 Scale)" = "LNtotSheltPeople",
                         "Total Unsheltered People(Log10 Scale)" = "LNtotUnsheltPeople",
                         "Total Sheltered People" = "totSheltPeople",
                         "Total Street Single Adult" = "totStreetSingAdult",
                         "Total Street Family Members" = "totStreetFamMem",
                         "Total Youth Family Households" = "totYouthFamHH",
                         "Total Unaccompanied Kids in Shelters" = "totUnAccMinor_sheltered",
                         "Total Single Youth in Shelters" = "totSingleYouth_sheltered")

    hcmapTool(inputDataset,inputGeolevel,category_HC)
  })
  ### Homelessness Page
  
  
  ### Shelter Page
  
  
  ### Crime Page
  output$map_crime = renderLeaflet({
    map_crime= filter(crime,TIME.OCCURRED>=input$range[1] &TIME.OCCURRED<=input$range[2] & CRIME.TYPE %in% input$crime_type)%>%
      leaflet()%>%
      addProviderTiles("CartoDB.Positron") %>%
      addMarkers(~LONGITUDE, ~LATITUDE,
                 clusterOptions=markerClusterOptions())
    map_crime
  })
  
  ### 311 Calls Page
  # 311 Calls Page - Map
  output$map_311calls = renderLeaflet({
    pal2 <- colorNumeric(
      palette = "YlOrRd",
      domain = calls311_merged$count_311calls
    )
    map2=leaflet() %>%
      setView(lng=-118.2437, lat=34.0522, zoom=10)%>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(data = calls311_merged, 
                  fillColor = ~pal2(count_311calls), 
                  color = "#b2aeae", # you need to use hex colors
                  fillOpacity = 0.7, 
                  weight = 1, 
                  smoothFactor = 0.2,
                  highlightOptions=highlightOptions(color="black", 
                                                    weight=2,
                                                    bringToFront=TRUE),
                  label=~as.character(count_311calls)) %>%
      addLegend(pal=pal2, values = calls311_count$count_311calls,opacity = 0.5)
    map2
  })
  # 311 Calls Page - Chart
  output$bar_311calls = renderPlot({
    calls311_count %>%
      arrange(desc(count_311calls)) %>%
      slice(1:as.numeric(input$top)) %>%
      ggplot(aes(x=reorder(factor(CT10), count_311calls),
                 y=count_311calls))+
      geom_bar(stat='identity')+
      labs(x="Census Tract Code", y="Count of 311 Calls")+
      coord_flip()
  })
}


