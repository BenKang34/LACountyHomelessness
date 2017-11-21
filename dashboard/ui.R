
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
             badgeLabel = "new", badgeColor = "green"),
    menuItem("311Calls", icon = icon("th"), tabName = "311calls",
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
                         selectInput("catHC",
                                     label = "Choose category of homeless people",
                                     choices = titles,
                                     selected = "Total Homeless"))))
    ),
    tabItem(tabName = "dashboard",
            h2("Homelessness tab content")),
    tabItem(tabName = "shelter",
            h2("Shelter tab content")),
    tabItem(tabName = "crime",
            fluidRow(
              box(leafletOutput("map_crime", height = 300,width=400)),
              
              box(
                title = "Time Interval",
                sliderInput("range", "Choose the time interval when the crime happened", 0, 24, value=c(4,18))
              )
            )
    ),
    tabItem(tabName = "311calls",
            h2("311 calls tab content"),
            
            #Main Display
            fluidRow(
              column(width = 9,
                     box(width = NULL, solidHeader = TRUE,
                         leafletOutput("map_311calls", height = 500))),
              #Right Side Display
              column(width = 3,
                     box(width = NULL, status = "warning",
                         selectInput('top', 'High Frequency 311 Calls Census Tracts',
                                     c('top five'=5,'top ten'=10,'top fifteen'=15),
                                     selected = 5)),
                     box(width = NULL, status = "warning",
                         plotOutput("bar_311calls", height = 200)
                     ))))
    
    
)
)

dashboardPage(
  header,
  sidebar,
  body
)