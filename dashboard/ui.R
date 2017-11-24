
library(shinydashboard)
library(leaflet)
#https://rstudio.github.io/shinydashboard/structure.html
#https://rstudio.github.io/leaflet/shiny.html

#

header = dashboardHeader(
  disable = TRUE,
  title = "City of Los Angeles",
  titleWidth = 180
)

sidebar = dashboardSidebar(
  width = 180,
  sidebarUserPanel(name = tags$p("City of Los Angeles", style = "font-size: 80%;"),#tags$a(href='https://www.lacity.org',
                                  #tags$img(src='logo.png'))#,"City of Los Angeles",
                   #subtitle = a(href = "https://www.lacity.org", icon("circle", class = "text-success"), "Online"),
                   # Image file should be in www/ subdir
                   image = "logo.png"
  ),
  sidebarMenu(
    #title = tags$a(href='https://www.lacity.org',
    #               tags$img(src='logo.png')),
    menuItem("Dashboard", icon = icon("dashboard"), tabName = "dashboard"),
    menuItem("Homelessness", icon = icon("users"), tabName = "homelessness"),
    menuItem("Shelter", icon = icon("home"), tabName = "shelter"),
    menuItem("Crime", icon = icon("th"), tabName = "crime"),
    menuItem("311 Calls", icon = icon("th"), tabName = "311calls")
    
    #badgeLabel = "new", badgeColor = "green"
  )
)

body = dashboardBody(
  tags$head(tags$style(HTML('
      .main-header .logo {
                            font-family: "Georgia", Times, "Times New Roman", serif;
                            font-weight: bold;
                            font-size: 14px;
      }
                            '))),
  tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
  tags$style(type = "text/css", "#map_crime_1 {height: calc(55vh - 70px) !important;}"),
  tags$style(type = "text/css", "#crime_line_1 {height: calc(45vh - 70px) !important;}"),
  tags$style(type = "text/css", "#map_311calls {height: calc(100vh - 80px) !important;}"),
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
            fluidRow(
              column(width = 9,
                     box(width = NULL,
                         leafletOutput("map_crime_1", height = 300)),
                     box(width = NULL,
                         title = "Crime Occurance Over Time",
                         plotOutput('crime_line_1', height = 300))
                     ),
              column(width = 3,
                     box(width = NULL,
                       textInput("ct_id_1", label = "Census Tract ID", value = "Enter the CT ID")),
                     box(width = NULL,
                         title = tags$p("Time Interval", style = "font-size: 100%;"),
                         sliderInput("range_1", 
                                     tags$p("Choose the time interval when the crime happened.", style = "font-size: 80%;"), 
                                     0, 2400, 
                                     value=c(400,1800),
                                     sep = "")),
                     box(width = NULL,
                         title = "Crime Type",
                         checkboxGroupInput("crime_type_1","Crime type to show:",
                                            c("ASSAULT","ROBBERY","THEFT","SEXUAL_CRIME"),
                                            selected = c("ASSAULT","ROBBERY","THEFT","SEXUAL_CRIME") ))
                     )
            )
    ),
    tabItem(tabName = "crime",
            fluidRow(
              box(
                textInput("ct_id", label = h3("Census Tract ID"), value = "Enter the ID of the CT that you concerned..."))
            ),
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