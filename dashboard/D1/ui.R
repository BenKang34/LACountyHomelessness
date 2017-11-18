library(shinydashboard)
library(leaflet)
#https://rstudio.github.io/shinydashboard/structure.html
#https://rstudio.github.io/leaflet/shiny.html

dataname = read.csv('dataname.csv')[,2]
header = dashboardHeader(
  title = "this is the title"
)

body = dashboardBody(
  fluidRow(
    column(width = 9,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("map", height = 500)
           )),
  fluidRow(  
    column(width = 3,
           box(width = NULL, status = "warning",
               uiOutput("geoSelect"),
               selectInput("geolevel", 
                          "Choose the geographical level:",
                           choices = c(
                                    'Cencus Tract Level' = 'tract',
                                    'Community Level' = 'Community_Name'
                                  ),
                          selected = 'Community_Name'
               ),
               p(
                 class = "text-muted",
                 paste("some random text for geo level")
               )
               #,actionButton("zoomButton", "Zoom to fit buses")
           ),
           
           
           box(width = NULL, status = "warning",
               selectInput("cat", "Choose category of homeless people",
                           choices = dataname,
                           selected = "totUnsheltPeople"
               ))
           )                      
           
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)