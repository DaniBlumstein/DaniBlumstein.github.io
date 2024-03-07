library(rsconnect)
rsconnect::setAccountInfo(name='104wj0-dani0blumstein',
                          token='AC72BFC5DD07BF3A53E1A9D62E0321F6',
                          secret='OO2SE3WHgkeY+DQ0St7GBYdNWjpP9PZoOaLH+1kd')

library(ggplot2)
library(shiny)
library(dplyr)
library(lubridate)
library(tidyverse)

df <- read.csv("diet_analysis_data.csv")

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
      h4("Description"),
      p("The desert simulation chamber has a photoperiodic cycle of 16 hours of light and 8 hours of darkness, with transitions occurring at 06:00 (dark to light) and 20:00 (light to dark) to mimic sunrise and sunset. 
               Under baseline circadian environmental conditions, the chamber is held at a temperature of 32°C during the light phase and relative humidity of 10% from 09:00 to 20:00. 
               At 20:00, the chamber temperature is decreased and humidity gradually increased over the course of one hour to 24°C and 25% RH, with lights-out at 20:00. 
               After 21:00, conditions are held constant over the dark phase until 06:00. At 06:00, where the light phase is initiated and there is a gradual 3-hour transition from cool temperatures and higher humidity (24°C and 25% RH) to warmer temperatures and lower humidity (32°C and 10% RH)."),
      br(),
      h4("Variables"),
      p("- EE = energy expenditure, the 'real' metaboic rate of an organism, often expressed in kiocalories per hour, 0.06 * (3.941 * VO2 + 1.106 * VCO2)"),
      p("- VO2 = rate of O2 consumption, often expressed as milliters per minute, per hour, or per second, FRdry*(delta_O2-deltaCO2*0.2095)/(1-0.2095)"),
      p("- VCO2 = rate of CO2 emission, often expressed as milliters per minute, per hour, or per second, FRdry*(DeltaCO2 +delta_O2*FiCO2)/(1+FiCO2)"),
      p("- H2Omg = rate of H2O emission, measured in miligrams per minute, per hour, or per second, 0.0803*FRdry*deltaH2O/(1-FiH2O)"),
      p("- RQ = respiratirt quotent. Typically falls within the rage of 0.7-1 for aerobic catabolism of fats and carbs, CO2 eliminated/O2 consumed"),
      p("- F =  female"),
      p("- M = male"),
      p("- Low Fat = measurments collected while on LabDiet 5015, Food quotent = (22.8/100).71+(6.6/100).83+.706 = .92266"),
      p("- hot = measurments collected under constant day time conditions, 32°C and relative humidity of 10%, and normal photoperiodic cycle"),
      p("- cold = measurments collected under constant night time conditions, 24°C and relative humidity of 25%, and normal photoperiodic cycle"),
      p("- night = a subset of the data for meauremtns takens only during the dark phase of the photoperiodic cycle",
      p("- day = a subset of the data for meauremtns takens only during the light phase of the photoperiodic cycle"),
      br(),
      h4("Additional information"),
      h5("MacManes Lab publications"),
      tags$a(href="https://www.biorxiv.org/content/10.1101/2020.12.18.423523v1.abstract", "Disentangling environmental drivers of circadian metabolism in desert-adapted mice", target="_blank"),
      br(),
      tags$a(href="https://www.biorxiv.org/content/10.1101/2020.06.29.178392v3", "Limited evidence for parallel evolution among desert adapted Peromyscus deer mice", target="_blank"),
      br(),
      tags$a(href=" https://doi.org/10.1111/mec.15401", "Comparative and population genomics approaches reveal the basis of adaptation to deserts in a small rodent", target="_blank"),
      br(),
      tags$a(href="https://doi.org/10.1101/2020.06.29.178392", "Multiple evolutionary pathways to achieve thermal adaptation in small mammals", target="_blank"),
      br(),
      tags$a(href="https://pubmed-ncbi-nlm-nih-gov.unh.idm.oclc.org/28645248/", "Characterizing the reproductive transcriptomic correlates of acute dehydration in males in the desert-adapted rodent, Peromyscus eremicus", target="_blank"),
      br(),
      tags$a(href="https://pubmed-ncbi-nlm-nih-gov.unh.idm.oclc.org/28381460/", "Severe acute dehydration in a desert rodent elicits a transcriptional response that effectively prevents kidney injury", target="_blank"),
      br(),
      tags$a(href="https://doi-org.unh.idm.oclc.org/10.14814/phy2.13218", "Physiological and biochemical changes associated with acute experimental dehydration in the desert adapted mouse, Peromyscus eremicus", target="_blank"),
      br(),
      tags$a(href="https://rdcu.be/cjrem", "Transcriptomic Evidence for Reproductive Suppression in Male Peromyscus eremicus (Cactus Mouse) Subjected to Acute Dehydration", target="_blank"),
      br(),
      tags$a(href="https://doi.org/10.1101/047704", "Physiological and biochemical changes associated with acute experimental dehydration in the desert adapted mouse, Peromyscus eremicus", target="_blank"),
      p("NIH Funding: 1R35GM128843"),
      h5("Source for equations"),
      tags$a(href="https://oxford.universitypressscholarship.com/view/10.1093/oso/9780198830399.001.0001/oso-9780198830399", "Link to Measuring Metabolic Rates: A Manual for Scientists
by John R. B. Lighton", target="_blank"),
      br(),
      h5("Shiny app DOI"),
      tags$a(href="https://zenodo.org/badge/latestdoi/194934393", img(src="https://zenodo.org/badge/194934393.svg"), alt="DOI", target="_blank"),
      br(),
      br(),
      img(src = "MacManesLab_v8.png", height = 100, width = 100),
      img(src = "nigms-logo.jpeg", height = 150, width = 150),
      img(src = "UNH.png", height = 80, width = 250)
    )
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


