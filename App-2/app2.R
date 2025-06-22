library(shiny)
library(dplyr)
library(visNetwork)
library(igraph)
library(scales)

# Color mappings
coul <- c(
  "trt" = "#fdc328", "iCa"="#f79342", "Crea"="#e4695e", "Cl"="#c23c81",
  "mean_RQ"="#920fa3", "AnGap"="#6c00a8", "mean_H2Omg"="#1fa088", 
  "Glu" = "#31688e", "BUN"="#886EA0", "K" = "darkgrey", "TCO2"= "#70809c",
  "Hct"= "plum", "mean_EE"="#4cc26c", "sex"="purple", "mass"="pink",
  "Na"="yellow", "Hb."="lightblue", "Osmolality"="tan"
)

cols <- c("kid"="#E3EB94", "liv"="#A9DAAF", "lu"="#94BEBD", "hyp"="#A47FC7", "gi"="#959BB8")

# UI ----
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .main-title {
        font-size: 2.5em;
        margin-bottom: 20px;
      }
      .sidebar-panel {
        padding: 20px;
        border-radius: 10px;
        color: white;
      }
      .main-panel {
        padding: 20px;
        border-radius: 10px;
      }
      .vis-network {
        height: 700px !important;
      }
    "))
  ),
  # Info Panel with Instructions and Links ----
  fluidRow(
    column(
      width = 4,
      wellPanel(
        div(class = "info-text",
            tags$h4("About This App"),
            tags$p("This application visualizes gene ontology results from two experiments: diet and water deprivation."),
            tags$h4("How to Use"),
            tags$ul(
              tags$li("Select a dataset from the dropdown on the left."),
              tags$li("Explore the network graph to see tissue-specific gene ontology associations."),
              tags$li("Hover over nodes to highlight connected tissues. Click and drag nodes or zoom in to make results easier to read.")
            ),
            tags$h4("Related Papers"),
            tags$ul(
              tags$li(
                tags$a(href = "https://journals.biologists.com/jeb/article/227/24/jeb247978/363474", 
                       "Impacts of dietary fat on multi tissue gene expression in the desert-adapted cactus mouse", target = "_blank")
              ),
              tags$li(
                tags$a(href = "https://link.springer.com/article/10.1186/s12864-024-10629-z", 
                       "The multi-tissue gene expression and physiological responses of water deprived Peromyscus eremicus", target = "_blank")
              )
            )
        )
      ),
      div(class = "sidebar-panel",
          helpText("Explore the unfiltered gene ontology results from either the diet experiment or the water deprivation expeiment."),
          selectInput("dataset_choice", label = "Choose Dataset:",
                      choices = c("diet" = "wgcna_data_go_diet.csv",
                                  "dehydration" = "go_wgcna_final_dehy.csv")),
          h5("Shiny app DOI"),
          tags$a(href="https://zenodo.org/badge/latestdoi/194934393", img(src="https://zenodo.org/badge/194934393.svg"), alt="DOI", target="_blank"),
          br(),
          br(),
          img(src = "MacManesLab_v8.png", height = 100, width = 100),
          img(src = "nigms-logo.jpeg", height = 150, width = 150),
          img(src = "UNH.png", height = 80, width = 250),
          hr()
      )
    ),
    column(
      width = 8,
      div(class = "main-panel",
          visNetworkOutput("network", height = "700px")
      ),
      h4("Description"),
      p("The desert simulation chamber has a photoperiodic cycle of 16 hours of light and 8 hours of darkness, with transitions occurring at 06:00 (dark to light) and 20:00 (light to dark) to mimic sunrise and sunset. 
               Under baseline circadian environmental conditions, the chamber is held at a temperature of 32°C during the light phase and relative humidity of 10% from 09:00 to 20:00. 
               At 20:00, the chamber temperature is decreased and humidity gradually increased over the course of one hour to 24°C and 25% RH, with lights-out at 20:00. 
               After 21:00, conditions are held constant over the dark phase until 06:00. At 06:00, where the light phase is initiated and there is a gradual 3-hour transition from cool temperatures and higher humidity (24°C and 25% RH) to warmer temperatures and lower humidity (32°C and 10% RH)."),
      br(),
      p("In the water deprivation experiment, mice were provided a standard diet and fed ad libitum (LabDiet® 5015*, 26.101% fat, 19.752% protein, 54.148% carbohydrates, energy 15.02 kJ/g, food quotient [FQ] 0.89). Animals were randomly selected and assigned to the two water treatment groups, with or without water for three day. "),
      br(),
      p("In the diet experiment, animals provided with water ad libitum, were randomly assigned to one of two diet groups, a standard diet group [SD – LabDiet® 5015*: 26.101% fat, 19.752% protein, 54.148% carbohydrate, energy 15.02 kJ g−1, FQ=0.89] or a low-fat diet group [LF diet – Modified LabDiet® 5015 (5G0Z), 6.6% fat, 22.8% protein, 70.6% carbohydrate, energy 14.31 kJ g−1, FQ=0.92].Prior to the beginning of the experiment, mice were fed the assigned diet for 4 weeks"),
      br(),
      p("At the conclusion of the experiments, body temperature was recorded (only in the water deprivation study), mice were weighed, animals were euthanized with an overdose of isoflurane, and 120 µl of trunk blood was collected for serum electrolyte measurement and analyzed. We measured the concentration of sodium (Na, mmol/L), potassium (K, mmol/L), blood urea nitrogen (BUN, mmol/L), hematocrit (Hct, % PCV), ionized calcium (iCa, mmol/L), glucose (Glu, mmol/L), osmolality (mmol/L), hemoglobin (Hb, g/dl), chlorine (Cl, mEq/L), total CO2 (TCO2, mmol/L), and Anion gap (AnGap, mEq/L). Using Na, Glu, and BUN, we calculated serum osmolality. We calculated the mean of the last hour of water loss, EE, and RQ for each mouse."),
      br(),
      br(),
    )
  )
)


# SERVER ----
server <- function(input, output, session) {
  
  data_input <- reactive({
    req(input$dataset_choice)
    validate(need(file.exists(input$dataset_choice), "File does not exist"))
    read.csv(input$dataset_choice)
  })
  
  network_data <- reactive({
    wgcna_data <- data_input()
    
    validate(need(all(c("V2", "tissue", "V3", "pheno") %in% names(wgcna_data)),
                  "Dataset missing required columns."))
    
    edges <- data.frame(
      to = wgcna_data$V2,
      from = wgcna_data$tissue,
      width = wgcna_data$V3,
      edge = wgcna_data$pheno
    )
    
    nodes <- dplyr::select(wgcna_data, V2, tissue) %>%
      arrange(V2) %>%
      filter(!duplicated(V2))
    
    # Add missing tissue nodes
    tissue_add <- data.frame(V2 = c("lu", "liv", "gi", "hyp", "kid"),
                             tissue = rep("tissue", 5))
    nodes <- rbind(nodes, tissue_add)
    
    colnames(nodes) <- c("label", "tissue")
    nodes$id <- nodes$label
    
    edges$width <- rescale(edges$width, to = c(1, 10))
    edges$color <- coul[as.character(edges$edge)]
    nodes$color.background <- cols[nodes$tissue]
    nodes$color.border <- cols[nodes$tissue]
    
    list(nodes = nodes, edges = edges)
  })
  
  output$value <- renderPrint({ input$dataset_choice })
  
  output$network <- renderVisNetwork({
    net_data <- network_data()
    
    visNetwork(net_data$nodes, net_data$edges) %>%
      visIgraphLayout() %>%
      visNodes(
        shape = "dot",
        shadow = list(enabled = TRUE, size = 10),
        font = list(size = 40)
      ) %>%
      visEdges(shadow = FALSE) %>%
      visOptions(
        highlightNearest = list(enabled = TRUE, degree = 1, hover = TRUE),
        selectedBy = "tissue"
      ) %>%
      visLayout(randomSeed = 11)
  })
}

# Run the app
shinyApp(ui = ui, server = server)
