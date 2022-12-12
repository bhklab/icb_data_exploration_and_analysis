library(shiny)
library(stringr)
library(data.table)
library(plotly)
library(pivottabler)
library(pheatmap)
library(viridis)

df_metadata<- read.table(file=file.path('data', 'merged_metadata.tsv'), header = TRUE, sep = '\t')
df_expr <- readRDS(file=file.path('data', 'merged_expr.rds'))

studies <- unique(df_metadata$study)
all.features <- list()
for(study in studies){
  patients <- rownames(df_metadata[df_metadata$study == study, ])
  expr <- df_expr[, colnames(df_expr)[colnames(df_expr) %in% patients]]
  expr <- expr[rowSums(!is.na(expr)) > 0, ]
  all.features[[study]] <- rownames(expr)
}

source('functions/getMetadataHeatmap.R')
source('functions/getPatientGeneNumberTable.R')
source('functions/getPatientGenePieCharts.R')

common_colnames <- c(
  "study", "sex","cancer_type","histo","treatmentid","stage","recist","response","treatment",
  "event_occurred_pfs","event_occurred_os", "survival_type"
)

getGenePatientPlots <- function(excluded_studies){
  plots <- list()

  num_studies <- length(studies)
  num_genes <- length(unique(unlist(all.features)))
  
  overlapping_genes_table <- matrix(nrow=num_studies, ncol=num_studies)
  for (i in 1:num_studies) {
    for (j in 1:num_studies) {
      overlapping_genes_table[i,j] <- length(base::intersect(all.features[[i]],all.features[[j]]))
    }
  }
  
  colnames(overlapping_genes_table) <- names(all.features)
  rownames(overlapping_genes_table) <- names(all.features)
  
  heatmap.table <- (overlapping_genes_table / num_genes) * 100
  
  plots[['geneOverlapHeatmap']] <- pheatmap(heatmap.table, color = viridis(30))
  pieCharts <- getPatientGenePieCharts(df_metadata, overlapping_genes_table, excluded_studies)
  plots[['genesPieChart']] <- pieCharts[['pie_genes']]
  plots[['patientsPieChart']] <- pieCharts[['pie_patients']]
  plots[['numPatients']] <- pieCharts[['num_patients']]
  plots[['numGenes']] <- pieCharts[['num_genes']]
  return(plots)
}

getMetadataPivotTable <- function(columns){
  pt <- PivotTable$new()
  pt$addData(df_metadata)
  for(column in columns){
    pt$addRowDataGroups(column, addTotal=FALSE)
  }
  pt$defineCalculation(calculationName="Total", summariseExpression="n()")
  pt$evaluatePivot()
  pt <- pivottabler(pt)
  return(pt)
}