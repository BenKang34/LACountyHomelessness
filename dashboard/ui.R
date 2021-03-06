
library(shinydashboard)
library(leaflet)
#https://rstudio.github.io/shinydashboard/structure.html
#https://rstudio.github.io/leaflet/shiny.html

#

header = dashboardHeader(
  title = "Homeless People Measures - City of Los Angeles",
  disable = TRUE#,
  #title = tags$a(href='https://www.lacity.org',
  #               tags$img(src='logo.png', width = "180px", height = "50px")),
  #titleWidth = 200
                 #"City of Los Angeles")
  #title = "City of Los Angeles"#,
 
)

#header$children[[2]]$children = tags$a(href='https://www.lacity.org',
#                                       tags$img(src='logo.png',title = "City of Los Angeles",height='40',width='40'))

sidebar = dashboardSidebar(
  width = 200,
  #sidebarUserPanel(name = tags$p("City of Los Angeles", style = "font-size: 80%;"),#tags$a(href='https://www.lacity.org',
  #                                #tags$img(src='logo.png'))#,"City of Los Angeles",
  #                 #subtitle = a(href = "https://www.lacity.org", icon("circle", class = "text-success"), "Online"),
  #                 # Image file should be in www/ subdir
  #                 image = "logo.png"
  #),
  sidebarMenu(
    #title = tags$a(href='https://www.lacity.org',
    #               tags$img(src='logo.png')),
    menuItem("Dashboard", icon = icon("dashboard"), tabName = "dashboard"),
    #menuItem("Homelessness", icon = icon("users"), tabName = "homelessness"),
    #menuItem("Shelter", icon = icon("home"), tabName = "shelter"),
    menuItem("Crime", icon = icon("th"), tabName = "crime"),
    menuItem("311 Calls", icon = icon("th"), tabName = "311calls")
    
    #badgeLabel = "new", badgeColor = "green"
  )
)

body = dashboardBody(
  #tags$head(
  #  tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
  #  tags$script(src = "custom.js")
  #),
  tags$style(type = "text/css", "#map {height: calc(80vh - 80px) !important;}"),
  tags$style(type = "text/css", "#map_crime_1 {height: calc(55vh - 70px) !important;}"),
  tags$style(type = "text/css", "#crime_line_1 {height: calc(45vh - 70px) !important;}"),
  tags$style(type = "text/css", "#map_311calls {height: calc(100vh - 80px) !important;}"),
  tags$style(type = 'text/css', ".selectize-input { font-size: 14px; line-height: 14px;} .selectize-dropdown { font-size: 10px; line-height: 12px; }"),
  tags$style(type = 'text/css', "table {
    border-spacing:0px; 
  }"),
  #tags$style(type = 'text/css', "table { border-collapse: collapse;}"),
  # Decide the number of Rows first, 
  # and then include the columns inside the Row(fluidRow)
  tabItems(
    tabItem(tabName = "dashboard",
            fluidRow(
              column(12,offset=0,
                     div(style = "font-size: 10px; padding: 14px 0px; margin-top:-3em",
                         tags$table(class = "table", style = "padding:0px;", tags$style(HTML("width:100%")),
                                    tags$tbody(tags$tr(tags$td(h4("Shelters Recommended"), style = "vertical-align:bottom", align = "left", width = "10000", tags$style(HTML("height:1000px"))),
                                                       tags$td(tags$a(href='https://www.lacity.org',
                                                                      tags$img(src='logo_b.png', width = "180px")),#, height = "50px")),
                                                               style = "border-collapse: collapse", align = "right", width = "10000", tags$style(HTML("height:1000px")))
                                                       )))
                         ),
                     div(style = "font-size: 10px; padding: 0px 0px; margin-top:-4.3em", 
                          fluidRow(
                            #red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, orange, fuchsia, purple, maroon, black.
                            valueBoxOutput("Rank1", width = 3),
                            valueBoxOutput("Rank2", width = 3),
                            valueBoxOutput("Rank3", width = 3),
                            valueBoxOutput("Rank4", width = 3)
                            #column(width = 12,
                            #       box(title = "Shelters Recommended", width = NULL, solidHeader = TRUE,
                                       
                            #           )
                            #)
                          )
                         ),
                     div(style = "font-size: 12px; padding: 14px 0px; margin-top:-3em",
                         tags$table(class = "table", style = "padding:0px;", tags$style(HTML("width:100%")),
                                    tags$tbody(tags$tr(tags$td(h4("Homeless People Measures"), style = "border-collapse: collapse", align = "left", width = "10000", tags$style(HTML("height:1000px")))
                                    )))
                     ),
                     div(style = "font-size: 12px; padding: 14px 0px; margin-top:-5em",
                          
                          #Main Display
                          fluidRow(
                            column(width = 9,
                                   box(width = NULL, solidHeader = TRUE,
                                       tags$head(tags$style(HTML("
                                                                 .marker-crime-small {
                                                                 background-color: rgba(254,232,200, 0.5);
                                                                 }
                                                                 .marker-crime-small div {
                                                                 background-color: rgba(253,187,132, 0.8);
                                                                 }
                                                                 
                                                                 .marker-crime-medium {
                                                                 background-color: rgba(253,187,132, 0.5);
                                                                 }
                                                                 .marker-crime-medium div {
                                                                 background-color: rgba(239,101,72, 0.8);
                                                                 }
                                                                 
                                                                 .marker-crime-large {
                                                                 background-color: rgba(239,101,72, 0.5);
                                                                 }
                                                                 .marker-crime-large div {
                                                                 background-color: rgba(179,0,0, 0.8);
                                                                 }"))),
                                       tags$head(tags$style(HTML("
                                                                 .marker-shelter-small {
                                                                 background-color: rgba(229,245,224, 0.5);
                                                                 }
                                                                 .marker-shelter-small div {
                                                                 background-color: rgba(161,217,155, 0.8);
                                                                 }
                                                                 
                                                                 .marker-shelter-medium {
                                                                 background-color: rgba(161,217,155, 0.5);
                                                                 }
                                                                 .marker-shelter-medium div {
                                                                 background-color: rgba(65,171,93, 0.8);
                                                                 }
                                                                 
                                                                 .marker-shelter-large {
                                                                 background-color: rgba(65,171,93, 0.5);
                                                                 }
                                                                 .marker-shelter-large div {
                                                                 background-color: rgba(0,109,44, 0.8);
                                                                 }"))),
                                       leafletOutput("map", height = 400))),
                          #Right Side Display
                            column(width = 3,
                                   box(width = NULL, status = "primary",
                                       uiOutput("geoSelect"),
                                       selectInput("geolevel", 
                                                   "Choose the geographical level:",
                                                   choices = c(
                                                     'City' = 'City',
                                                     'Community' = 'Community',
                                                     'Census Tract' = 'CensusTract'
                                                   ),
                                                   selected = 'Community'
                                       )#,
                                       #p(
                                      #   class = "text-muted",
                                      #   paste("some random text for geo level")
                                      # )
                                       #,actionButton("zoomButton", "Zoom to fit buses")
                                   ),
                                   box(width = NULL, status = "primary",
                                       selectInput("catHC",
                                                   label = "Choose the category of homeless measures:",
                                                   choices = titles,
                                                   selected = "Total Unsheltered People"))))
                     )
              )
            )
    ),
    tabItem(tabName = "homelessness",
            fluidRow(
              column(width = 9,
                     box(width = NULL, solidHeader = TRUE,
                         leafletOutput("map_hc", height = 500))))),
    tabItem(tabName = "crime",
            fluidRow(
              column(width = 7,
                     div(style = "font-size: 12px; padding: 14px 0px; margin-top:-3em",
                         tags$table(class = "table", style = "padding:0px;", tags$style(HTML("width:100%")),
                                    tags$tbody(tags$tr(tags$td(h4("Crime Distribution"), style = "border-collapse: collapse", align = "left", width = "10000", tags$style(HTML("height:1000px")))
                                    )))
                     ),
                     div(style = "font-size: 12px; padding: 14px 0px; margin-top:-5em",
                         box(width = NULL,
                             leafletOutput("map_crime", height = 670))
                     )
                     ),
              column(width = 5,
                     #box(width = NULL,
                    #   textInput("ct_id", label = "Census Tract ID", value = "Enter the CT ID")),
                    div(style = "font-size: 12px; padding: 14px 0px; margin-top:-3em",
                        tags$table(class = "table", style = "padding:0px;", tags$style(HTML("width:100%")),
                                   tags$tbody(tags$tr(tags$td(h4("Daily Crime Trend"), style = "border-collapse: collapse", align = "left", width = "10000", tags$style(HTML("height:1000px")))
                                   )))
                    ),
                    div(style = "font-size: 12px; padding: 14px 0px; margin-top:-5em",
                      fluidRow(
                        column(width = 7, 
                               box(width = NULL, height = 200,
                                   title = tags$p("Time Interval", style = "font-size: 80%;"),
                                   sliderInput("range", 
                                               tags$p("Choose the time interval when the crime happened.", style = "font-size: 90%;"), 
                                               0, 2400, 
                                               value=c(400,1800),
                                               sep = ""))
                               ),
                        column(width = 5,
                               box(width = NULL, height = 200,
                                   title = tags$p("Crime Type", style = "font-size: 80%;"),
                                   checkboxGroupInput("crime_type",
                                                      tags$p("Crime type to show:", style = "font-size: 90%;"), 
                                                      c("ASSAULT","ROBBERY","THEFT","SEXUAL_CRIME"),
                                                      selected = c("ASSAULT","ROBBERY","THEFT","SEXUAL_CRIME") ))
                               )
                        ),
                      fluidRow(
                        column(width = 12,
                               box(width = NULL,
                                   #title = "Crime Occurance Over Time",
                                   plotOutput('crime_line', height = 450))
                        )
                        )
                    )
                    )
              )
    ),
    tabItem(tabName = "311calls",
            #h2("311 calls tab content"),
            
            #Main Display
            fluidRow(
              column(width = 12,
                     div(style = "font-size: 12px; padding: 14px 0px; margin-top:-3em",
                         tags$table(class = "table", style = "padding:0px;", tags$style(HTML("width:100%")),
                                    tags$tbody(tags$tr(tags$td(h4("311 Calls: Homeless Encampment"), style = "border-collapse: collapse", align = "left", width = "10000", tags$style(HTML("height:1000px")))
                                    )))
                     ),
                     div(style = "font-size: 12px; padding: 14px 0px; margin-top:-5em",
                         fluidRow(
                           column(width = 7,
                                  box(width = NULL, solidHeader = TRUE,
                                      leafletOutput("map_311calls", height = 500))),
                           #Right Side Display
                           column(width = 5,
                                  box(width = NULL, status = "primary",
                                      selectInput('top', 'High Frequency 311 Calls Census Tracts',
                                                  c('Top 5'=5,'Top 10'=10,'Top 15'=15),
                                                  selected = 5)),
                                  box(width = NULL, status = "primary",
                                      plotOutput("bar_311calls", height = 565)
                                      )
                                  )
                           )
                         )
              )
            )
    )
    )
)

dashboardPage(
  header,
  sidebar,
  body
)