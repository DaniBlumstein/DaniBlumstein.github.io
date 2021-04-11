#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(ggplot2)
library(shiny)


#df <- rbind(modified, hot, cold, baseline)
#saveRDS(df, file = "my_data.rds")
df <- readRDS(file = "my_data.rds")


# Define UI ----
ui <- fluidPage(
    titlePanel("Cactus Mouse Phsiology"),
    sidebarLayout(
        sidebarPanel(
            img(src = "EfEZPI_VAAAZlSv.jpeg", height = 70, width = 200),
            br(),
            span("@marshalhedin", style = "color:blue"),
            helpText("Create graphs of the various data I've collected"),
            
            selectInput("var", 
                        label = "Choose a variable to display",
                        choices = list("VO2", 
                                       "VCO2",
                                       "Deg_C", 
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
                       "Deg_C" = df$Deg_C,
                       "H2Omg" = df$H2Omg,
                       "EE" = df$EE,
                       "RQ" = df$RQ)
        switch (input$checkGroup,
                "TimeOfDay" = df$TimeOfDay,
                "Sex" = df$StartTime,
                "experiment" = df$experiment)
        case = action
    })
    
    
    output$plot<-renderPlot({
        ggplot(df,aes_string(x=df$StartTime,y=input$var,color=input$checkGroup))+
            geom_point()+
            scale_color_brewer(palette="Dark2")},
        height = 400,width = 600)
}

# Run the app ----
shinyApp(ui = ui, server = server)
