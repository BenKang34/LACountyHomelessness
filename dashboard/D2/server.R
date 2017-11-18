library(ggplot2)
library(dplyr)

function(input, output) {
  
  data = reactive({
      data = read.csv('mdata.csv')
      data=data %>%
      mutate_(factor = input$factor,geo=input$geo)%>%
      group_by(geo) %>%
      select(c(geo,factor)) %>%
      summarise(factor = mean(factor)) %>%
      arrange(desc(factor)) %>%
      slice(1:input$percentage) 
      data
    })

  #output table
  output$table = renderTable({
      data.frame(data())
  })
  #output plot
  #output$table = DT::renderDataTable(DT::datatable
  output$plot = renderPlot({
    data() %>%
      ggplot(aes(x=factor(geo), y = factor)) + geom_bar(stat='identity')+coord_flip()
  })  

}