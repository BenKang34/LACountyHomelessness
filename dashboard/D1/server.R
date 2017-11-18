library(shinydashboard)
library(leaflet)
library(dplyr)
library(rgdal)  


## ----Import-Shapefile----------------------------------------------------

# Import a polygon shapefile: readOGR("path","fileName")
# no extension needed as readOGR only imports shapefiles
#aoiBoundary_HARV <- readOGR("NEON-DS-Site-Layout-Files/HARV",
#                            "HarClip_UTMZ18")

#aoiBoundary_HARV <- readOGR("Communities1",
#                            "Communities")
#aoiBoundary_HARV <- readOGR("CAMS_ZIPCODE_PARCEL_SPECIFIC",
#                            "CAMS_ZIPCODE_PARCEL_SPECIFIC")
#-----------------------------------------------------------

#https://stackoverflow.com/questions/33045388/projecting-my-shapefile-data-on-leaflet-map-using-r
geo =readOGR('./CENSUS_TRACTS_2010','CENSUS_TRACTS_2010')
shapeData <- spTransform(geo, CRS("+proj=longlat +datum=WGS84 +no_defs"))

function(input, output) {
  #data
  data = reactive({
    data = read.csv('mdata.csv')
    data=data %>%
      mutate_(cat = input$cat,geo=input$geolevel)%>%
      dplyr::select(cat,geo,long,lat) %>%
      mutate(long = as.numeric(long),lat = as.numeric(lat))%>%
      slice(1:100)
    data = data.frame(data)
    data
  })
  
  #geo level
  #output$geolevel <- renderUI({
    
  #})
  
  output$map = renderLeaflet({
    map = leaflet() %>%
      addPolygons(data=shapeData,
                  color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 1.0, fillOpacity = 0.5,
                  #fillColor = ~colorQuantile("YlOrRd", data()$cat)(data()$cat),
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE))%>%
      addProviderTiles(providers$CartoDB.Positron)  %>%
      addMarkers(
        lng=data()$long,
        lat=data()$lat
      )
    map
  })

}
#    if (as.numeric(input$routeNum) != 0) {
#      route_shape <- get_route_shape(input$routeNum)
#      map = addPolylines(map,
#                          route_shape$shape_pt_lon,
#                          route_shape$shape_pt_lat,
#                          fill = FALSE
#      )
      
#    }
