library(tidycensus)
library(tidyverse)
census_api_key("5f4c45000052e3b7cb3b9e925f5c31d045ed0f93", install = TRUE)






la_pop <- get_acs(geography = "tract",
                  variables = "B01003_001",
                  state = "CA",
                  county = "Los Angeles",
                  geometry = TRUE)
?get_acs


library(stringr)

ca_pop$ct = str_sub(ca_pop$GEOID, 6)





library(leaflet)
library(stringr)
library(sf)
pal1 <- colorQuantile(palette = "viridis", domain = ca_pop$estimate, n = 10)

ca_pop %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width = "100%") %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(popup = ~ str_extract(NAME, "^([^,]*)"),
              stroke = FALSE,
              smoothFactor = 0,
              fillOpacity = 0.7,
              color = ~ pal(estimate)) %>%
  addLegend("bottomright", 
            pal = pal1, 
            values = ~ estimate,
            title = "Population percentiles",
            opacity = 1)




























