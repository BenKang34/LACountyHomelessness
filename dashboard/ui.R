
library(shinydashboard)
library(leaflet)
#https://rstudio.github.io/shinydashboard/structure.html
#https://rstudio.github.io/leaflet/shiny.html

#

header = dashboardHeader(
  title = "City of Los Angeles"
)

sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", icon = icon("dashboard"), tabName = "dashboard"),
    menuItem("Homelessness", icon = icon("users"), tabName = "homelessness"),
    menuItem("Shelter", icon = icon("home"), tabName = "shelter"),
    menuItem("Crime", icon = icon("th"), tabName = "crime"),
    menuItem("311 Calls", icon = icon("th"), tabName = "311calls")
    
    #badgeLabel = "new", badgeColor = "green"
  )
)

body = dashboardBody(
  # Decide the number of Rows first, 
  # and then include the columns inside the Row(fluidRow)
  tabItems(
    tabItem(tabName = "dashboard",
            #h2("Dashboard tab content"),
            
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
                                       'City' = 'City',
                                       'Community' = 'Community',
                                       'Census Tract' = 'CensusTract'
                                     ),
                                     selected = 'City'
                         )#,
                         #p(
                        #   class = "text-muted",
                        #   paste("some random text for geo level")
                        # )
                         #,actionButton("zoomButton", "Zoom to fit buses")
                     ),
                     box(width = NULL, status = "warning",
                         selectInput("catHC",
                                     label = "Choose the category of homeless people",
                                     choices = titles,
                                     selected = "Total Unsheltered People"))))
    ),
    tabItem(tabName = "homelessness",
            fluidRow(
              column(width = 9,
                     box(width = NULL, solidHeader = TRUE,
                         leafletOutput("map_hc", height = 500))))),
    tabItem(tabName = "shelter",
            h2("Shelter tab content")),
    tabItem(tabName = "crime",
            fluidRow(
              box(width = 12,
                  leafletOutput("map_crime", height = 350))),
            fluidRow( 
              box(width = 12,
                title = "Time Interval",
                sliderInput("range", "Choose the time interval when the crime happened.", 0, 2400, value=c(400,1800))
              )
            ),
            fluidRow(
              box(title = "Crime Type",
                  checkboxGroupInput("crime_type","Crime type to show:",
                                     c("ASSAULT","ROBBERY","THEFT","SEXUAL_CRIME"),
                                     selected = c("ASSAULT","ROBBERY","THEFT","SEXUAL_CRIME") ))),
            fluidRow(  
              box(width=12,title = "Crime Occurance Over Time",
                  plotOutput('crime_line')
                  ))
    ),
    tabItem(tabName = "311calls",
            #h2("311 calls tab content"),
            
            #Main Display
            fluidRow(
              column(width = 7,
                     box(width = NULL, solidHeader = TRUE,
                         leafletOutput("map_311calls", height = 500))),
              #Right Side Display
              column(width = 5,
                     box(width = NULL, status = "warning",
                         selectInput('top', 'High Frequency 311 Calls Census Tracts',
                                     c('top five'=5,'top ten'=10,'top fifteen'=15),
                                     selected = 5)),
                     box(width = NULL, status = "warning",
                         plotOutput("bar_311calls", height = 350)
                     ))))
    
    #tags$style(type = "text/css", ".box-body {height:80vh}"),
)
)

dashboardPage(
  header,
  sidebar,
  body
)