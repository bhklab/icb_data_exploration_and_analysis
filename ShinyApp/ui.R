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
        h3("Analysis Parameters"),
      ),
      mainPanel(
        width=10,
        plotOutput("metadataHeatmap", width='700px', height='400px'),
        plotOutput('geneOverlapHeatmap', width='700px'),
        fluidRow(
          column(
            width=5, 
            plotlyOutput('genesPieChart')
          ),
          column(
            width=5,
            plotlyOutput('patientsPieChart')
          )
        )
      )
    )
  )
)