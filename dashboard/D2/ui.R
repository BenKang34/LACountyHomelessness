dataname = read.csv('dataname.csv')[,2]
fluidPage(
  titlePanel('this is the title for table'),
  sidebarLayout(sidebarPanel(
    # Input: Selector for choosing geo level ----
    selectInput(inputId = "geo",
                label = "Choose a geographical level:",
                choices = c('Community_Name','Tract'),
                selected = 'Community_Name'),
    # Input: Selector for choosing risk factor ----
    selectInput(inputId = "factor",
                label = "Choose a risk factor:",
                choices = dataname,
                selected = 'totUnsheltPeople'),
    #Input: select percentage
    radioButtons(inputId = 'percentage',
                 label = 'Choose the top',
                 choices = c("5%" = 5,"10%" = 10,"15%" = 15),
                 selected = 5)
  ),
  mainPanel(
    # Output: Verbatim text for data summary ----
    verbatimTextOutput("summary"),
    # Output: HTML table with requested number of observations ----
    plotOutput('plot'),
    tableOutput("table")
  ))
  # Main panel for displaying outputs ----

  # Create a new row for the table.
  #fluidRow(
  #  DT::dataTableOutput("table")
  #)
)