library(rsconnect)
rsconnect::setAccountInfo(name='104wj0-dani0blumstein',
                          token='6558579B24BDD9974D8411F722FEFD66',
                          secret='hf5NT9bDE6WJIFmAY0ure3gTKfwTPkK5MYxnEm9H')

library(ggplot2)
library(shiny)
library(dplyr)
library(lubridate)
library(tidyverse)

#setwd("~/Documents/DaniBlumstein.github.io/App-1")

#df <- rbind(modified, hot, cold, baseline)
#saveRDS(df, file = "my_data.rds")

#df <- readRDS(file = "www/my_data.rds")
#write.csv(df,"\\MyData.csv", row.names = FALSE)

df <- read.csv("MyData.csv")

sex_list <- unique(df$Sex)
experiment_list <- unique(df$experiment)
time_list <- unique(df$TimeOfDay)
columns <- names(df)

# Define UI ----
ui <- fluidPage(
  titlePanel("Cactus Mouse Physiology"),
  sidebarLayout(
    sidebarPanel(
      #HTML('<img src="../EfEZPI_VAAAZlSv.jpeg", height="400px"    
          #style="float:right"/>','<p style="color:black"></p>'),
      img(src = "118481971_623307748555991_7327762981189400276_n.jpg", height = 200, width = 255),
      br(),
      helpText("Create graphs of the various data I've collected under different experimental conditions in our temperature controlled colony."),
      selectInput("var", 
                  label = "Choose a variable to display",
                  choices = list("VO2", 
                                 "VCO2",
                                 "H2Omg",
                                 "EE",
                                 "RQ"),
                  selected = "EE"),
      
      # Copy the chunk below to make a group of checkboxes
      checkboxGroupInput('sex', 'Sex',
                         sex_list,
                         selected = sex_list),
      checkboxGroupInput('exp', 'Experiment',
                         experiment_list,
                         selected = experiment_list),
      checkboxGroupInput('time', 'Time',
                         time_list,
                         selected = time_list),

  hr(),
  fluidRow(column(3, verbatimTextOutput("value")))),
    mainPanel(
      plotOutput("plot"),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      p("The desert simulation chamber has a photoperiodic cycle of 16 hours of light and 8 hours of darkness, with transitions occurring at 06:00 (dark to light) and 20:00 (light to dark) to mimic sunrise and sunset. 
               Under circadian environmental conditions, the chamber is held at a temperature of 32°C during the light phase and relative humidity of 10% from 09:00 to 20:00. 
               At 20:00, the chamber temperature is decreased and humidity gradually increased over the course of one hour to 24°C and 25% RH, with lights-out at 20:00. 
               After 21:00, conditions are held constant over the dark phase until 06:00. At 06:00, where the light phase is initiated and there is a gradual 3-hour transition from cool temperatures and higher humidity (24°C and 25% RH) to warmer temperatures and lower humidity (32°C and 10% RH)."),
      br(),
      tags$a(href="https://www.biorxiv.org/content/10.1101/2020.12.18.423523v1.full", "Link to publication with temperature experiments"),
      br(),
      br(),
      img(src = "MacManesLab_v8.png", height = 100, width = 100),
      img(src = "nigms-logo.jpeg", height = 150, width = 150),
      img(src = "UNH.png", height = 80, width = 250)
    )
  )
)


server <- function(input, output) {
  
  filteredData <- reactive({
    df %>% filter(Sex %in% input$sex &
                      experiment %in% input$exp &
                      TimeOfDay %in% input$time )
  })
  
  
  selectedData <- reactive({
    filteredData() %>% 
      select_(.dots = columns)
  })

  output$plot<-renderPlot({
    ggplot(selectedData(),aes(x=as.POSIXct(hms(StartTime),origin = "1964-10-22"), color = experiment, shape=Sex))+
      geom_point(aes_string(y=input$var))+
      scale_colour_viridis_d()+
      #theme(axis.text.x = element_blank())+
      labs(x = "hour")+
      scale_x_datetime(date_breaks = "3 hours", date_labels = "%H:%M")
    },
    height = 600,width = 800)
  }

# Run the app ----
shinyApp(ui = ui, server = server)


