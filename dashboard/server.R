library(shinydashboard)
library(leaflet)
library(tidycensus)
library(tidyverse)
library(sf)

###Make a map of homeless count




###a function that takes in a homeless count measure, 
###and return a color pallette based on the data
palfunc<-function(LAmapdata,hc,color="YlOrRd"){
  pal <- colorBin(
    palette = color, #"Reds"
    domain = LAmapdata@data[,hc],
    bins = 10,#bins,
    na.color = "#808080")#,
    #pretty = FALSE
}

labels_hc <- function(strGeo,value) {
  if(typeof(value) == "double") {
    labels <- sprintf(
      "<strong>%s</strong><br/>%.3g", #/ mi<sup>2</sup>
      strGeo, value
    ) %>% lapply(htmltools::HTML)
  }
  else if(typeof(value) == "integer") {
    labels <- sprintf(
      "<strong>%s</strong><br/>%i", #/ mi<sup>2</sup>
      strGeo, value
    ) %>% lapply(htmltools::HTML)
  }
  else{
    labels <- sprintf(
      "<strong>%s</strong><br/>%s", #/ mi<sup>2</sup>
      strGeo, as.character(value)
    ) %>% lapply(htmltools::HTML)
  }
}

###a function that take in a dataset and homeless count measure, and create a map
###including both homeless count, crime count and shelters

hcmapTool<-function(LAmapdata,geolevel,hc,color="YlOrRd"){

  ##creat a palette for the hc variable  
  pal<-palfunc(LAmapdata,hc,color)
  leaflet(LAmapdata) %>%
    ## Base Groups
    addProviderTiles("CartoDB.Positron", group="County Map") %>% 
    addPolygons(
                fillColor = ~pal(LAmapdata@data[,hc]), 
                color = "#b2aeae", # you need to use hex colors
                fillOpacity = 0.7, 
                weight = 1, 
                smoothFactor = 0.2,
                label=labels_hc(LAmapdata@data[,geolevel],LAmapdata@data[,hc]),
                labelOptions = labelOptions(
                  style = list("font-weight" = "normal", padding = "3px 8px"),
                  textsize = "15px",
                  direction = "auto"),
                highlightOptions=highlightOptions(color="black", 
                                                  weight=2,
                                                  bringToFront=TRUE),
                group="Homeless Density")%>%
    addLegend(pal = pal, 
              values = ~LAmapdata@data[,hc], 
              position = "bottomright",
              opacity = 1,
              title = titles[match(hc, vars)]) %>%#, #the the index of hc, and then get the title
              #labFormat = labelFormat(suffix = "") )%>%#,
              #group="Homeless Density Legend") 
    addMarkers(data=crime, ~LONGITUDE, ~LATITUDE,
               label="crime",
               labelOptions=labelOptions(style=list("color"="red")),
               clusterOptions=markerClusterOptions(iconCreateFunction=JS("function (cluster) {    
    var childCount = cluster.getChildCount(); 
    var c = ' marker-crime-';  
    if (childCount > 100) {  
      c += 'large';  
    } else if (childCount > 30) {  
      c += 'medium';  
    } else { 
      c += 'small';  
    }    
    return new L.DivIcon({ html: '<div><span>' + childCount + '</span></div>', className: 'marker-cluster' + c, iconSize: new L.Point(40, 40) });
                                                   
    }")),
               group="Crime Count 2016~2017") %>%
    addMarkers(data=shelter, ~LONGITUDE, ~LATITUDE,
               clusterOptions=markerClusterOptions(iconCreateFunction=JS("function (cluster) {    
    var childCount = cluster.getChildCount(); 
    var c = ' marker-shelter-';  
    if (childCount > 50) {  
      c += 'large';  
    } else if (childCount > 10) {  
      c += 'medium';  
    } else { 
      c += 'small';  
    }    
    return new L.DivIcon({ html: '<div><span>' + childCount + '</span></div>', className: 'marker-cluster' + c, iconSize: new L.Point(40, 40) });

    }")),
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

## Shiny App Server Function
function(input, output) {
  
  RankDataInput <- reactive({
     if (input$catHC %in% c("Total Unsheltered People","Total Sheltered People","Total Street Single Adult","Total Street Family Members","Total Youth Family Households","Total Unaccompanied Kids in Shelters","Total Unaccompanied Kids in Shelters", "Total Single Youth in Shelters" )) {
       crime_ratio = switch(input$catHC,
                            "Total Unsheltered People" = hc2017_ct_subset.comm$CrimeUnsheltRatio,
                            "Total Sheltered People" = hc2017_ct_subset.comm$CrimeSheltRatio,
                            "Total Street Single Adult" = hc2017_ct_subset.comm$CrimeSSARatio,
                            "Total Street Family Members" = hc2017_ct_subset.comm$CrimeSFMRatio,
                            "Total Youth Family Households" = hc2017_ct_subset.comm$CrimeYFHRatio,
                            "Total Unaccompanied Kids in Shelters" = hc2017_ct_subset.comm$CrimeUAMRatio,
                            "Total Single Youth in Shelters" = hc2017_ct_subset.comm$CrimeSYRatio)
       calls_ratio = switch(input$catHC,
                            "Total Unsheltered People" = hc2017_ct_subset.comm$CallsUnsheltRatio,
                            "Total Sheltered People" = hc2017_ct_subset.comm$CallsSheltRatio,
                            "Total Street Single Adult" = hc2017_ct_subset.comm$CallsSSARatio,
                            "Total Street Family Members" = hc2017_ct_subset.comm$CallsSFMRatio,
                            "Total Youth Family Households" = hc2017_ct_subset.comm$CallsYFHRatio,
                            "Total Unaccompanied Kids in Shelters" = hc2017_ct_subset.comm$CallsUAMRatio,
                            "Total Single Youth in Shelters" = hc2017_ct_subset.comm$CallsSYRatio)
     } else{crime_ratio=hc2017_ct_subset.comm$CrimeUnsheltRatio
     calls_ratio=hc2017_ct_subset.comm$CallsUnsheltRatio}

     
       maxCrime <- max(hc2017_ct_subset.comm$CrimeUnsheltRatio, na.rm = T)
       maxCalls <- max(hc2017_ct_subset.comm$CallsUnsheltRatio, na.rm = T)
       maxSheltersToTotalpeople <- max(hc2017_ct_subset.comm$TotPeopleSheltersRatio, na.rm = T) 
       hc2017_ct_subset.comm$RankShelterLocation = (w1*(crime_ratio/maxCrime)^2+
                           w2*(calls_ratio/maxCalls)^2+
                           w3*(hc2017_ct_subset.comm$TotPeopleSheltersRatio/maxSheltersToTotalpeople)^2)  

    hc2017_ct_subset.comm %>%        
      filter(Community %in% CommunityInLACitylist) %>%
      select(Community, totUnsheltPeople, count_shelter, RankShelterLocation) %>%
      arrange(-RankShelterLocation)%>%
      slice(1:4)
  })
  
  ### Dashboard Page
  output$Rank1 = renderValueBox({
    valueBox(
      tags$p(RankDataInput()$Community[1], style = "font-size: 40%;"), 
      tags$p(HTML(paste(paste("Unsheltered People:",RankDataInput()$totUnsheltPeople[1]),
                        paste("Number of Shelters:",RankDataInput()$count_shelter[1]),
                        sep="<br/>")), style = "font-size: 100%;"),
      width = 3, 
      color = "navy"
    )
  })
  output$Rank2 = renderValueBox({
    valueBox(
      tags$p(RankDataInput()$Community[2], style = "font-size: 40%;"), 
      tags$p(HTML(paste(paste("Unsheltered People:",RankDataInput()$totUnsheltPeople[2]),
                        paste("Number of Shelters:",RankDataInput()$count_shelter[2]),
                        sep="<br/>")), style = "font-size: 100%;"),
      width = 3, 
      color = "navy"
    )
  })
  output$Rank3 = renderValueBox({
    valueBox(
      tags$p(RankDataInput()$Community[3], style = "font-size: 40%;"), 
      tags$p(HTML(paste(paste("Unsheltered People:",RankDataInput()$totUnsheltPeople[3]),
                        paste("Number of Shelters:",RankDataInput()$count_shelter[3]),
                        sep="<br/>")), style = "font-size: 100%;"),
      width = 3, 
      color = "navy"
    )
  })
  output$Rank4 = renderValueBox({
    valueBox(
      tags$p(RankDataInput()$Community[4], style = "font-size: 40%;"), 
      tags$p(HTML(paste(paste("Unsheltered People:",RankDataInput()$totUnsheltPeople[4]),
                 paste("Number of Shelters:",RankDataInput()$count_shelter[4]),
                 sep="<br/>")), style = "font-size: 100%;"), 
      width = 3, 
      color = "navy"
    )
  })
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
                         "Total Sheltered People" = "totSheltPeople",
                         "Total Street Single Adult" = "totStreetSingAdult",
                         "Total Street Family Members" = "totStreetFamMem",
                         "Total Youth Family Households" = "totYouthFamHH",
                         "Total Unaccompanied Kids in Shelters" = "totUnAccMinor_sheltered",
                         "Total Single Youth in Shelters" = "totSingleYouth_sheltered",
                         "Total Unsheltered People(2016)" = "totUnsheltPeople.2016",
                         "Crime Counts" = "count_crime",
                         "311 Calls Counts" = "count_311calls",
                         "Shelter Counts" = "count_shelter",
                         "Change of Total Unsheltered People" = "totUnsheltChanges",
                         "Total Sheltered People(Log10 Scale)" = "LNtotSheltPeople",
                         "Total Unsheltered People(Log10 Scale)" = "LNtotUnsheltPeople",
                         "Crimes to Unsheltered People Ratio" = "CrimeUnsheltRatio",
                         "311 Calls to Unsheltered People Ratio" = "CallsUnsheltRatio",
                         "Total Homeless People to Shelters Ratio" = "TotPeopleSheltersRatio",
                         "Shelters to be located" = "RankShelterLocation"
                         )
    color_HC = switch(input$catHC,
                         "Total Homeless People" = "Blues", 
                         "Total Unsheltered People" = "Blues",
                         "Total Sheltered People" = "Blues",
                         "Total Street Single Adult" = "Blues",
                         "Total Street Family Members" = "Blues",
                         "Total Youth Family Households" = "Blues",
                         "Total Unaccompanied Kids in Shelters" = "Blues",
                         "Total Single Youth in Shelters" = "Blues",
                         "Total Unsheltered People(2016)" = "Blues",
                         "Crime Counts" = "Blues",
                         "311 Calls Counts" = "Blues",
                         "Shelter Counts" = "Blues",
                         "Change of Total Unsheltered People" = "RdBu",
                         "Total Sheltered People(Log10 Scale)" = "Blues",
                         "Total Unsheltered People(Log10 Scale)" = "Blues",
                         "Crimes to Unsheltered People Ratio" = "Blues",
                         "311 Calls to Unsheltered People Ratio" = "Blues",
                         "Total Homeless People to Shelters Ratio" = "Blues",
                         "Shelters to be located" = "Blues"
    )

    hcmapTool(inputDataset,inputGeolevel,category_HC,color_HC)
  })
  ### Homelessness Page
  output$map_hc = renderLeaflet({
    #hcmapTool(hc2017_merged,"tract","totUnsheltCrimeRatio",color = "RdBu")
    hcmapTool(hc2017_merged,"tract","totUnsheltCrimeRatio",color = "Reds")
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
    icon = ifelse(getColor(crime) == "pink", 
                  'female', 
                  ifelse(getColor(crime) == 'blue', 'male', 'genderless')),#'ios-close',
    iconColor = 'black',
    library = 'ion',
    markerColor = getColor(crime)
  )
  
  
  output$map_crime = renderLeaflet({
    map_crime <- crime %>%
      filter(TIME.OCCURRED>=input$range[1] &TIME.OCCURRED<=input$range[2] & CRIME.TYPE %in% input$crime_type) %>%
      leaflet()%>%
      addProviderTiles("CartoDB.Positron") %>%
      addAwesomeMarkers(~LONGITUDE, ~LATITUDE,icon=icons,
                        #clusterOptions=markerClusterOptions(),
                        popup = ~as.character((paste(sep = "<br/>",DATE.OCCURRED,CRIME.CODE.DESCRIPTION,"Victim Age:",VICTIM.AGE))))
    
    map_crime
  })
  
  output$crime_line = renderPlot({
    crime %>%
      mutate(hour = as.integer(TIME.OCCURRED/100))%>%
      filter(CRIME.TYPE %in% input$crime_type)%>%
      group_by(hour,CRIME.TYPE)%>%
      summarise(total = n()) %>%
      ggplot(aes(x=hour,
                 y=total,
                 col = CRIME.TYPE))+
      geom_line()+
      labs(x="Crime Occurance Time (Hour)", y="Count of Crimes")+
      scale_x_continuous(breaks = seq(0,23,1))+
      theme(legend.position = "bottom")
  })  
  ### 311 Calls Page
  # 311 Calls Page - Map
  output$map_311calls = renderLeaflet({
    pal2 <- colorNumeric(
      palette = "Blues",
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
                  label=labels_hc(calls311_merged@data[,"CT10"],calls311_merged@data[,"count_311calls"]))%>%
                  #label=~as.character(count_311calls)) %>%
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


