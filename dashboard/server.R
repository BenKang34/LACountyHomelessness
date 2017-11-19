library(shinydashboard)
library(leaflet)
library(tidycensus)
library(tidyverse)
library(sf)


# ----Import-Shapefile----------------------------------------------------
census_api_key("5f4c45000052e3b7cb3b9e925f5c31d045ed0f93")
la_pop = get_acs(geography = "tract",
                 variables = "B01003_001",
                 state = "CA",
                 county = "Los Angeles",
                 geometry = TRUE)
la_pop$ct = str_sub(la_pop$GEOID, 6)
#pal1 = colorQuantile(palette = "viridis", domain = la_pop$estimate, n = 10)
hc2017_ct_subset$totUnsheltPeople = as.numeric(hc2017_ct_subset$totUnsheltPeople)
hc2017_ct_subset = hc2017_ct_subset %>%
  mutate(totUnsheltPeople = ifelse(is.na(totUnsheltPeople),0,totUnsheltPeople))
#pal1 = colorQuantile(palette = "viridis", hc2017_ct_subset$totUnsheltPeople, n = 10)
pal1 = colorBin("viridis", hc2017_ct_subset$totUnsheltPeople, 10, pretty = TRUE)
#-----------------------------------------------------------
data = crime

function(input, output) {
  
  #data
  #data = reactive({
  #})
  
  #
  
  #map
  output$map = renderLeaflet({
    map = hc2017_ct_subset %>%
      st_transform(crs = "+init=epsg:4326") %>%
      leaflet(width = "100%") %>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      addPolygons(popup = ~str_extract(NAME, "^([^,]*)"),
                  stroke = FALSE,
                  smoothFactor = 0,
                  fillOpacity = 0.7,
                  color = ~pal1(totUnsheltPeople))%>%
      addLegend("bottomright", 
                pal = pal1, 
                values = ~ totUnsheltPeople,
                title = "Population percentiles",
                opacity = 1)#%>%
      #addMarkers(lng=data$LONGITUDE,
      #           lat=data$LATITUDE)
    
    map
  })
}

