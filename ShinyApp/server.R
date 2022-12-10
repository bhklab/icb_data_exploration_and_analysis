library(shiny)
library(stringr)
library(data.table)
library(plotly)
library(pivottabler)

server <- function(input, output){
  metadataHeatmap <- getMetadataHeatmap(df_metadata, studies)
  output$metadataHeatmap <- renderPlot(
    metadataHeatmap
  )
  
  excluded_studies <- c('Puch', 'Shiuan', 'Liu', 'Padron', 'VanDenEnde', 'Snyder', 'Hwang', 'Jerby_Arnon', 'Roh', 'Mariathasan')
  plots <- getGenePatientPlots(excluded_studies)
  
  output$geneOverlapHeatmap <- renderPlot(
    plots[['geneOverlapHeatmap']]
  )
  output$genesPieChart <- renderPlotly(
    plots[['genesPieChart']]
  )
  output$patientsPieChart <- renderPlotly(
    plots[['patientsPieChart']]
  )
}