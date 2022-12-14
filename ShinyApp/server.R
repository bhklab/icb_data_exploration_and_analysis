library(shiny)
library(pivottabler)

server <- function(input, output){
  
  #Reactive Values
  Query <- reactiveValues(
    studies = NULL, 
    excluded_studies = NULL,
    columns = c(),
    cancer_type = c(),
    treatment = c()
  )
  
  observeEvent(
    input$studies,
    {
      Query$studies <- input$studies
      Query$excluded_studies <- studies[!studies %in% input$studies]
    }
  )
  
  observeEvent(
    input$columns,
    {
      if(length(input$columns) == 0){
        Query$columns <- c()
      }else{
        if(length(Query$columns) > length(input$columns)){
          Query$columns <- Query$columns[Query$columns %in% input$columns]
        }
        if(length(Query$columns) < length(input$columns)){
          Query$columns <- c(Query$columns, input$columns[!input$columns %in% Query$columns])
        }
      }
    }
  )
  
  observeEvent(
    input$cancer_type,
    {
      Query$cancer_type <- input$cancer_type
    }
  )
  
  observeEvent(
    input$treatment,
    {
      Query$treatment <- input$treatment
    }
  )
  
  observe({
    metadataHeatmap <- getMetadataHeatmap(df_metadata, Query$studies)
    output$metadataHeatmap <- renderPlot(
      metadataHeatmap
    )
  })
  
  observe({
    if(length(Query$columns) > 0){
      output$metadataPivotTable <- renderPivottabler(
        getMetadataPivotTable(
          Query$columns, 
          Query$cancer_type, 
          Query$treatment
        )
      )
    }
  })
  
  observe({
    plots <- getGenePatientPlots(Query$excluded_studies)
    
    output$geneOverlapHeatmap <- renderPlot(
      plots[['geneOverlapHeatmap']]
    )
    output$genesPieChart <- renderPlotly(
      plots[['genesPieChart']]
    )
    output$patientsPieChart <- renderPlotly(
      plots[['patientsPieChart']]
    )
    output$numPatients <- renderText(paste0("<b>", plots[['numPatients']], "</b>", " patients available"))
    output$numGenes <- renderText(paste0("<b>", plots[['numGenes']], "</b>", " genes available"))
  })
  
  output$patientGeneNumberTable <- renderTable(
    getPatientGeneNumberTable(studies, df_metadata, all.features)
  )

}