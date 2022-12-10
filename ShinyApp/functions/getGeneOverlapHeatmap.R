library(pheatmap)
library(viridis)

getGeneOverlapHeatmap <- function(df_metadata, all.features, overlapping_genes_table, studies, excluded_studies=c()){
  
  studies_common_genes <- studies[!studies %in% excluded_studies]
  temp.features <- all.features[names(all.features)[!names(all.features) %in% excluded_studies]]
  
  num_studies <- length(studies_common_genes)
  num_genes <- length(unique(unlist(temp.features)))
  
  overlapping_genes_table <- matrix(nrow=num_studies, ncol=num_studies)
  for (i in 1:num_studies) {
    for (j in 1:num_studies) {
      overlapping_genes_table[i,j] <- length(base::intersect(temp.features[[i]],temp.features[[j]]))
    }
  }
  
  colnames(overlapping_genes_table) <- names(temp.features)
  rownames(overlapping_genes_table) <- names(temp.features)
  
  heatmap.table <- (overlapping_genes_table / num_genes) * 100
  
  return(
    pheatmap(heatmap.table, color = viridis(30))
  )
}