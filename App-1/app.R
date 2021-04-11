
library(rsconnect)
rsconnect::setAccountInfo(name='104wj0-dani0blumstein', token='6558579B24BDD9974D8411F722FEFD66', secret='hf5NT9bDE6WJIFmAY0ure3gTKfwTPkK5MYxnEm9H')

library(ggplot2)
library(shiny)


#df <- rbind(modified, hot, cold, baseline)
#saveRDS(df, file = "my_data.rds")

#df <- readRDS(file = "www/my_data.rds")
#write.csv(df,"\\MyData.csv", row.names = FALSE)

df <- read.csv("MyData.csv")

# Define UI ----
ui <- fluidPage(
  titlePanel("Cactus Mouse Physiology"),
  sidebarLayout(
    sidebarPanel(
      #HTML('<img src="../EfEZPI_VAAAZlSv.jpeg", height="400px"    
          #style="float:right"/>','<p style="color:black"></p>'),
      img(src = "EfEZPI_VAAAZlSv.jpeg", height = 200, width = 250),
      br(),
      span("Photo credit @marshalhedin", style = "color:blue"),
      helpText("Create graphs of the various data I've collected"),
      
      selectInput("var", 
                  label = "Choose a variable to display",
                  choices = list("VO2", 
                                 "VCO2",
                                 "H2Omg",
                                 "EE",
                                 "RQ"),
                  selected = "EE"),
      
      # Copy the chunk below to make a group of checkboxes
      checkboxGroupInput("checkGroup", 
                  label = "Treatments", 
                  choices = list("TimeOfDay" = "TimeOfDay",
                                 "Sex"= "Sex",
                                 "experiment" = "experiment"),
                  selected = "experiment"),

  hr(),
  fluidRow(column(3, verbatimTextOutput("value")))),
    mainPanel(plotOutput("plot"))
  ))

server <- function(input, output) {
  output$plot <- renderPlot({
    data <- switch(input$var, 
                   "VO2" = df$VO2,
                   "VCO2" = df$VCO2,
                   "H2Omg" = df$H2Omg,
                   "EE" = df$EE,
                   "RQ" = df$RQ)
            switch (input$checkGroup,
                    "Time of Day" = df$TimeOfDay,
                    "Sex" = df$StartTime,
                    "Experiment" = df$experiment)
      case = action
  })
    
  
  output$plot<-renderPlot({
    ggplot(df,aes(x=StartTime))+
      geom_point(aes_string(y=input$var, color=input$checkGroup))+
      scale_color_brewer(palette="Dark2")+
      labs(x = "hours")},
    height = 400,width = 600)
  }

# Run the app ----
shinyApp(ui = ui, server = server)

#```

