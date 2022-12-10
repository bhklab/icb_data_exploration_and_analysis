library(plotly)

### pie chart for patient and gene availability (depth and breadth) ###

getPatientGenePieCharts <- function(df_metadata, overlapping_genes_table, excluded_studies){
  all_patients <- length(rownames(df_metadata))
  all_genes <- range(overlapping_genes_table)[2]
  
  available_studies <- df_metadata[!df_metadata$study %in% excluded_studies, ]
  available_patients <- length(rownames(available_studies))
  
  overlapping_genes <- overlapping_genes_table[
    !rownames(overlapping_genes_table) %in% excluded_studies, 
    !colnames(overlapping_genes_table) %in% excluded_studies
  ]
  available_genes <- range(overlapping_genes)[1]
  
  colors <- c('#FF7F0E', '#c6c6c6')
  available_patients_pct <- (available_patients/all_patients) * 100
  patients <- data.frame(
    availability=c('available', 'unavailable'), 
    percentage=c(available_patients_pct, 100 - available_patients_pct)
  )
  
  # number of patients
  pie_patients <- plot_ly(
    patients, 
    labels = ~availability, 
    values = ~percentage, 
    marker = list(colors = colors),
    type = 'pie',
    textfont = list(size = 40)
  )
  pie_patients <- pie_patients %>% 
    layout(
      title = '',
      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
      legend = list(font = list(size = 20))
    )
  
  # number of genes
  available_genes_pct <- (available_genes/all_genes) * 100
  genes <- data.frame(
    availability=c('available', 'unavailable'), 
    percentage=c(available_genes_pct, 100 - available_genes_pct)
  )
  pie_genes <- plot_ly(
    genes, 
    labels = ~availability, 
    values = ~percentage, 
    marker = list(colors = colors),
    type = 'pie',
    textfont = list(size = 40)
  )
  pie_genes <- pie_genes %>% 
    layout(
      title = '',
      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
      legend = list(font = list(size = 20))
    )
  return(list(
    pie_patients=pie_patients,
    pie_genes=pie_genes
  ))
}
