navbarPage("Superzip", id="nav",
  tabPanel("Interactive map",           
    # If not using custom CSS, set height of leafletOutput to a number instead of percent
    leafletOutput("map", width="500", height="100%"),
    
    # Shiny versions prior to 0.11 should use class = "modal" instead.
    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 330, height = "auto",
    h2("ZIP explorer"),
                                      
    selectInput('top', 'Top ', c('5'=5,'10'=10,'15'=15),selected = 5),
    #selectInput("size", "Size", vars, selected = "adultpop"),
    #conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
    # Only prompt for threshold when coloring or sizing by superzip
    #numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
    #                                 ),
                                      
    plotOutput("bar", height = 200)
                        )
           )
)


