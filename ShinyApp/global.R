library("shiny")

df_metadata<- read.table(file=file.path('data', 'merged_metadata.tsv'), header = TRUE, sep = '\t')
df_expr <- read.table(file=file.path('data', 'merged_expr.tsv'), header = TRUE, sep = '\t')

studies <- unique(df_metadata$study)
all.features <- list()
for(study in studies){
  patients <- rownames(df_metadata[df_metadata$study == study, ])
  expr <- df_expr[, colnames(df_expr)[colnames(df_expr) %in% patients]]
  expr <- expr[rowSums(!is.na(expr)) > 0, ]
  all.features[[study]] <- rownames(expr)
}

source('functions/getMetadataHeatmap.R')
source('functions/getGeneNumberTable.R')
source('functions/getPatientGenePieCharts.R')

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
  return(plots)
}