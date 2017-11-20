library(shiny)
library(ggplot2)
library(tidycensus)
library(tidyverse)
library(leaflet)

function(input, output) {
  
  output$map = renderLeaflet({
    pal2 = colorNumeric(
      palette = "YlOrRd",
      domain = calls311_merged$count_311calls
    )
    
    map2=leaflet() %>%
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
  })
  
  output$bar = renderPlot({
    calls311_count %>%
      arrange(desc(count_311calls)) %>%
      slice(numeric(input$top)) %>%
      ggplot(aes(x=CT10,y=count_311calls))+geom_bar(stat='identity')+coord_flip()
  })

}


#data = reactive({
#  data = read.csv('mdata.csv')
#  data=data %>%
#    mutate_(factor = input$factor,geo=input$geo)%>%
#    group_by(geo) %>%
#    select(c(geo,factor)) %>%
#    summarise(factor = mean(factor)) %>%
#    arrange(desc(factor)) %>%
#    slice(1:input$percentage) 
#  data
#})

