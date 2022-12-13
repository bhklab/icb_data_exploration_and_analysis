library("shiny")
library("shinycssloaders")

ui <- fluidPage(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    sidebarLayout(
      sidebarPanel(
        width=2,
        checkboxGroupInput(
          inputId='studies',
          label='Studies to include',
          choices = studies,
          selected = studies
        )
      ),
      mainPanel(
        width=10,
        tabsetPanel(
          tabPanel(
            "Clinical Metadata", 
            h4('Availability of clinical metadata in each study'),
            plotOutput("metadataHeatmap", width='700px', height='400px'),
            h4('Clinical metadata pivot table'),
            checkboxGroupInput(
              inputId='columns',
              label='Select metadata values:',
              choices = common_colnames,
              selected = c('study'),
              inline = TRUE,
              width = NULL,
            ),
            conditionalPanel(
              condition='input.columns.includes("cancer_type")',
              checkboxGroupInput(
                inputId='cancer_type',
                label='Select cancer types to include:',
                choices = cancer_types,
                selected = cancer_types,
                inline = TRUE,
                width = NULL,
              ),
            ),
            conditionalPanel(
              condition='input.columns.includes("treatment")',
              checkboxGroupInput(
                inputId='treatment',
                label='Select treatment value to include:',
                choices = treatments,
                selected = treatments,
                inline = TRUE,
                width = NULL,
              ),
            ),
            pivottablerOutput('metadataPivotTable')
          ), 
          tabPanel(
            "Patient Gene Numbers", 
            fluidRow(
              column(
                width=5,
                h4('Number of patients and genes in each study'),
                tableOutput('patientGeneNumberTable')
              )
            ),
          ), 
          tabPanel(
            "Gene-Patient Data",
            fluidRow(
              column(
                width=10,
                h4('Overlapping genes across studies'),
                plotOutput('geneOverlapHeatmap', width='700px'),
              )
            ),
            fluidRow(
              column(
                width=5,
                h4('Available patients'),
                htmlOutput('numPatients'),
                plotlyOutput('patientsPieChart')
              ),
              column(
                width=5, 
                h4('Available genes'),
                htmlOutput('numGenes'),
                plotlyOutput('genesPieChart')
              ),
            )
          ), 
        )
      )
    )
  )
)