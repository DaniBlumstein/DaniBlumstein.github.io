
library(devtools)
##install_version("ggplot2", version = "3.3.3", repos = "http://cran.us.r-project.org")
library(shiny)
library(dplyr)
library(lubridate)
library(tidyverse)
library(rsconnect)


rsconnect::setAccountInfo(name='104wj0-dani0blumstein', 
                          token='6558579B24BDD9974D8411F722FEFD66', 
                          secret='hf5NT9bDE6WJIFmAY0ure3gTKfwTPkK5MYxnEm9H')

df <- read.csv("data_final.csv")

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
                                 "H2Og",
                                 "EE_kJH",
                                 "RQ"),
                  selected = "EE_kJH"),
      
      # Copy the chunk below to make a group of checkboxes
      checkboxGroupInput('Sex', 'Sex',
                         sex_list,
                         selected = sex_list),
      checkboxGroupInput('experiment', 'experiment',
                         experiment_list,
                         selected = experiment_list),
      checkboxGroupInput('TimeOfDay', 'TimeOfDay',
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
      p("- EE_kJH = energy expenditure, the 'real' metaboic rate of an organism, often expressed in kiocalories per hour, 4.1868*0.06*(3.941*VO2 + 1.106*VCO2)"),
      p("- VO2 = rate of O2 consumption, often expressed as milliters per minute, per hour, or per second, FRdry*(delta_O2-deltaCO2*0.2095)/(1-0.2095)"),
      p("- VCO2 = rate of CO2 emission, often expressed as milliters per minute, per hour, or per second, FRdry*(DeltaCO2 +delta_O2*FiCO2)/(1+FiCO2)"),
      p("- H2Omg = rate of H2O emission, measured in milliters per minute, per hour, or per second, 0.0803*FRdry*deltaH2O/(1-FiH2O)"),
      p("- RQ = respirometry quotent. Typically falls within the rage of 0.7-1 for aerobic catabolism of fats and carbs, CO2 eliminated/O2 consumed"),
      p("- Low Fat = measurments collected while on LabDiet 5015, Food quotent = (22.8/100).71+(6.6/100).83+.706 = .92266"),
      p("- hot = measurments collected under constant day time conditions, 32°C and relative humidity of 10%, and normal photoperiodic cycle"),
      p("- cold = measurments collected under constant night time conditions, 24°C and relative humidity of 25%, and normal photoperiodic cycle"),
      p("- night = a subset of the data for measurments takens only during the dark phase of the photoperiodic cycle",
      p("- day = a subset of the data for measurments takens only during the light phase of the photoperiodic cycle"),
      p("- T1 = a subset of the data for measurments takens only during first transistion of the photoperiodic cycle"),
      p("- T2 = a subset of the data for measurments takens only during second transistion of the photoperiodic cycle"),
      p("- baseline, standard, yes water = measurments collected under constant day time conditions and normal photoperiodic cycle"),
      p("- day 1,2,3,and 4 no water = measurments collected under constant day time conditions and normal photoperiodic cycle for mice without access to water for 1,2,3, and 4 days"),
      
      
      br(),
      h4("Additional information"),
      h5("MacManes Lab publications"),
     
      
      tags$a(href="https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-024-10629-z", "The multi-tissue gene expression and physiological responses of water deprived Peromyscus eremicus", target="_blank"),
      br(),
      tags$a(href="https://www.researchgate.net/publication/380424236_SURVIVAL_STRATEGIES_IN_ARID_ENVIRONMENTS_EXPLORING_DESERT_ADAPTATIONS_IN_PEROMYSCUS_EREMICUS?_sg%5B0%5D=cObGFnbBRFqjDYtkZQ6zktVYMF4FyQYMPO-ps878Mr2zhewZ1RUbXdSvITkDSull32FGSe9uhbh8TO7Z63KG7o0UHTXxibxV0ux7K001.sDa4jZ5_DV8xNByyFvE5UF7iyZs5g-iWoU-hPJ6z5QFG0lJy5PE5ZuFJsS9D0lHH8biVW1Hf50BgHy2gyAn0Iw&_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6ImhvbWUiLCJwYWdlIjoicHJvZmlsZSIsInByZXZpb3VzUGFnZSI6InByb2ZpbGUiLCJwb3NpdGlvbiI6InBhZ2VDb250ZW50In19", "Survival Strategies in Arid Environments: Exploring Desert Adaptations in Peromyscus eremicus. PhD dissertation. University of New Hampshire.", target="_blank"),
      br(),
      tags$a(href="https://www.unh.edu/unhtoday/2024/05/desert-mice-offer-insight-potential-climate-change-adaptations", "UNH Today: Desert Mice Offer Insight into Potential Climate Change Adaptations", target="_blank"),
      br(),
      tags$a(href="https://journals-biologists-com.unh.idm.oclc.org/jeb/article/226/23/jeb246924/335759/Parched-cactus-mice-save-water-by-curbing-their", "Inside JEB Feature: Parched cactus mice save water by curbing their appetite", target="_blank"),
      br(),
      tags$a(href="https://journals-biologists-com.unh.idm.oclc.org/jeb/article/226/23/jeb246936/335760/ECR-Spotlight-Danielle-Blumstein", "JEB ECR Spotlight – Danielle Blumstein", target="_blank"),
      br(),
      tags$a(href="https://journals-biologists-com.unh.idm.oclc.org/jeb/article/226/23/jeb246386/335758/When-the-tap-runs-dry-the-physiological-effects-of", "When the tap runs dry: the physiological effects of acute experimental dehydration in Peromyscus eremicus ", target="_blank"),
      br(),
      tags$a(href="https://www.biorxiv.org/content/10.1101/2024.05.03.592397v1.abstract", "Impacts of dietary fat on multi tissue gene expression in the desert-adapted cactus mouse", target="_blank"),
      br(),
      tags$a(href="https://www.biorxiv.org/content/10.1101/2022.04.15.488461v3.abstract", "High total water loss driven by low-fat diet in desert-adapted mice", target="_blank"),
      br(),
      tags$a(href="https://journals-biologists-com.unh.idm.oclc.org/jeb/article/224/18/jeb242529/272300/Disentangling-environmental-drivers-of-circadian", "Disentangling environmental drivers of circadian metabolism in desert-adapted mice", target="_blank"),
      br(),
      tags$a(href="https://academic-oup-com.unh.idm.oclc.org/jhered/article/112/3/286/6158454", "Limited evidence for parallel evolution among desert adapted Peromyscus deer mice", target="_blank"),
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
    df %>% filter(Sex %in% input$Sex &
                      experiment %in% input$experiment &
                      TimeOfDay %in% input$TimeOfDay )
  })
  
  
  selectedData <- reactive({
    filteredData() %>% 
      select_(.dots = columns)
  })

  output$plot<-renderPlot({
    ggplot(selectedData(),aes(x=as.POSIXct(hms(StartTime),origin = "1970-01-01"), color = experiment, shape=Sex))+
      scale_x_datetime(date_breaks = "3 hours", date_labels = "%H:%M")+
      annotate("rect", xmin = as.POSIXct("1970-01-01 00:00:01", tz="UTC"), 
               xmax = as.POSIXct("1970-01-01 06:00:00", tz="UTC"), 
               ymin = -Inf, ymax = Inf, fill="grey84") +
      annotate("rect", xmin = as.POSIXct("1970-01-01 21:00:00", tz="UTC"), 
               xmax = as.POSIXct("1970-01-01 23:59:59", tz="UTC"), 
               ymin = -Inf, ymax = Inf, fill="grey84") +
      geom_point(aes_string(y=input$var),alpha=.3, size=1)+
      geom_smooth(aes_string(y=input$var),method='gam',se = FALSE)+
      theme_minimal()+
      facet_wrap(~Sex)+
      labs(x = "hour")
    },
    height = 600,width = "auto")
}

rsconnect::appDependencies()

# Run the app ----
shinyApp(ui = ui, server = server)


