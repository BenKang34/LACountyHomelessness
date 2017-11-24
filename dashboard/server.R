library(shinydashboard)
library(leaflet)
library(tidycensus)
library(tidyverse)
library(sf)

###Make a map of homeless count




###a function that takes in a homeless count measure, 
###and return a color pallette based on the data
palfunc<-function(hc,color="YlOrRd"){
  pal <- colorBin(
    palette = "Reds",
    domain = hc,
    bins = 7,#bins,
    na.color = "#808080")
}

labels_hc <- function(geolevel,hc) {
  strTmp = as.character(hc)
  labels <- sprintf(
    "<strong>%s</strong><br/>%s", #/ mi<sup>2</sup>
    geolevel, 
    ifelse(str_detect(strTmp,"[.]"),
           str_sub(strTmp,1,str_locate(strTmp,"[.]")[1]+2),
           strTmp)
    #ifelse(typeof(unlist(LAmapdata@data[hc]))=="double",
    #       as.character(unlist(LAmapdata@data[hc])),
    #       sprintf("%i people",unlist(LAmapdata@data[hc])))
  ) %>% lapply(htmltools::HTML)
}

###a function that take in a dataset and homeless count measure, and create a map
###including both homeless count, crime count and shelters

hcmapTool<-function(LAmapdata,geolevel,hc,legend_title,color="YlOrRd"){

  ##creat a palette for the hc variable  
  pal<-palfunc(hc,color)
  leaflet(LAmapdata) %>%
    ## Base Groups
    addProviderTiles("CartoDB.Positron", group="County Map") %>% 
    addPolygons(fillColor = ~pal(hc),#LAmapdata@data[hc]), 
                color = "#b2aeae", # you need to use hex colors
                fillOpacity = 0.7, 
                weight = 1, 
                smoothFactor = 0.2,
                label=labels_hc(geolevel,hc),
                labelOptions = labelOptions(
                  style = list("font-weight" = "normal", padding = "3px 8px"),
                  textsize = "15px",
                  direction = "auto"),
                highlightOptions=highlightOptions(color="black", 
                                                  weight=2,
                                                  bringToFront=TRUE),
                group="Homeless Density")%>%
    addLegend(pal = pal, 
              values = ~hc, 
              position = "bottomright",
              opacity = 1,
              title = legend_title) %>%#, #the the index of hc, and then get the title
              #labFormat = labelFormat(suffix = "") )%>%#,
              #group="Homeless Density Legend") 
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
                          'CensusTract' = inputDataset$"tract",
                          'Community' = inputDataset$"Community",
                          'City' = inputDataset$"City"
                          )
    category_HC = switch(input$catHC,
                         "Total Homeless People" = inputDataset$totPeople, 
                         "Total Unsheltered People" = inputDataset$totUnsheltPeople,
                         "Total Sheltered People(Log10 Scale)" = inputDataset$LNtotSheltPeople,
                         "Total Unsheltered People(Log10 Scale)" = inputDataset$LNtotUnsheltPeople,
                         "Total Sheltered People" = inputDataset$totSheltPeople,
                         "Crime to Unsheltered People Ratio" = inputDataset$CrimeUnsheltRatio,
                         "311 Calls to Unsheltered People Ratio" = inputDataset$CallsUnsheltRatio,
                         "Change of Total Unsheltered People" = inputDataset$totUnsheltChanges,
                         "Total Street Single Adult" = inputDataset$totStreetSingAdult,
                         "Total Street Family Members" = inputDataset$totStreetFamMem,
                         "Total Youth Family Households" = inputDataset$totYouthFamHH,
                         "Total Unaccompanied Kids in Shelters" = inputDataset$totUnAccMinor_sheltered,
                         "Total Single Youth in Shelters" = inputDataset$totSingleYouth_sheltered)

    hcmapTool(inputDataset,inputGeolevel,category_HC,input$catHC)
  })
  ### Homelessness Page
  output$map_hc = renderLeaflet({
    #hcmapTool(hc2017_merged,"tract","totUnsheltCrimeRatio",color = "RdBu")
    hcmapTool(hc2017_merged,hc2017_merged$tract,hc2017_merged$totUnsheltCrimeRatio,color = "Reds")
  })
  
  ### Shelter Page
  
  
  ### Crime Page
  
  # marker color
  getColor <- function(crime) {
    sapply(crime$VICTIM.SEX, function(gender) {
      if(gender == "F") {
        "pink"
      } else if(gender == "M") {
        "blue"
      } else {
        "grey"
      } })
  }
  
  icons <- awesomeIcons(
    icon = 'ios-close',
    iconColor = 'black',
    library = 'ion',
    markerColor = getColor(crime)
  )
  
  output$map_crime = renderLeaflet({
    map_crime= filter(crime,TIME.OCCURRED>=input$range[1] &TIME.OCCURRED<=input$range[2] & CRIME.TYPE %in% input$crime_type)%>%
      leaflet()%>%
      addProviderTiles("CartoDB.Positron") %>%
      addAwesomeMarkers(~LONGITUDE, ~LATITUDE,icon=icons,
                        clusterOptions=markerClusterOptions(),
                        popup = ~as.character((paste(sep = "<br/>",DATE.OCCURRED,CRIME.CODE.DESCRIPTION,"Victim Age:",VICTIM.AGE))))
    
    map_crime
  })
  
  # Crime Page - line Chart
  output$crime_line = renderPlot({
    crime %>%
      mutate(hour = as.integer(TIME.OCCURRED/100))%>%
      filter(CRIME.TYPE %in% input$crime_type)%>%
      group_by(hour,CRIME.TYPE)%>%
      summarise(total = n())%>%
      ggplot(aes(x=hour,
                 y=total,
                 col = CRIME.TYPE))+
      geom_line()+
      labs(x="Crime Occurance Time", y="Count of Crimes")+
      scale_x_continuous(breaks = seq(0,23,1))
  }) 
  
  ###### Ben's version of crime: Just rearranged
  output$map_crime_1 = renderLeaflet({
    map_crime= filter(crime,TIME.OCCURRED>=input$range[1] &TIME.OCCURRED<=input$range[2] & CRIME.TYPE %in% input$crime_type)%>%
      leaflet()%>%
      addProviderTiles("CartoDB.Positron") %>%
      addAwesomeMarkers(~LONGITUDE, ~LATITUDE,icon=icons,
                        #clusterOptions=markerClusterOptions(),
                        popup = ~as.character((paste(sep = "<br/>",DATE.OCCURRED,CRIME.CODE.DESCRIPTION,"Victim Age:",VICTIM.AGE))))
    
    map_crime
  })
  output$crime_line_1 = renderPlot({
    crime %>%
      mutate(hour = as.integer(TIME.OCCURRED/100))%>%
      filter(CRIME.TYPE %in% input$crime_type)%>%
      group_by(hour,CRIME.TYPE)%>%
      summarise(total = n())%>%
      ggplot(aes(x=hour,
                 y=total,
                 col = CRIME.TYPE))+
      geom_line()+
      labs(x="Crime Occurance Time", y="Count of Crimes")+
      scale_x_continuous(breaks = seq(0,23,1))
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


