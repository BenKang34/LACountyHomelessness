library(shinydashboard)
library(leaflet)
#https://rstudio.github.io/shinydashboard/structure.html
#https://rstudio.github.io/leaflet/shiny.html

#

header = dashboardHeader(
  title = "Homelessness - Los Angeles County"
)

sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", icon = icon("dashboard"), tabName = "dashboard"),
    menuItem("Homelessness", icon = icon("users"), tabName = "homelessness",
             badgeLabel = "new", badgeColor = "green"),
    menuItem("Shelter", icon = icon("home"), tabName = "shelter",
             badgeLabel = "new", badgeColor = "green"),
    menuItem("Crime", icon = icon("th"), tabName = "crime",
             badgeLabel = "new", badgeColor = "green")
  )
)

body = dashboardBody(
  # Decide the number of Rows first, 
  # and then include the columns inside the Row(fluidRow)
  tabItems(
    tabItem(tabName = "dashboard",
            h2("Dashboard tab content"),
            
            #Main Display
            fluidRow(
              column(width = 9,
                     box(width = NULL, solidHeader = TRUE,
                         leafletOutput("map", height = 500))),
            #Right Side Display
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
                                     choices = c("DR.NUMBER", "b", "c"),
                                     selected = "totUnsheltPeople"))))
    ),
    tabItem(tabName = "dashboard",
            h2("Homelessness tab content")),
    tabItem(tabName = "shelter",
            h2("Shelter tab content")),
    tabItem(tabName = "crime",
            h2("Crime tab content"))
  )
)

dashboardPage(
  header,
  sidebar,
  body
)