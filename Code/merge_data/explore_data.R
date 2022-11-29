library(stringr)
library(data.table)
library(plotly)
library(pheatmap)
library(viridis)

input_dir <- '~/Data/merged'

df_merged <- read.table(file=file.path(input_dir, 'merged_metadata.tsv'), header = TRUE, sep = '\t')
studies <- unique(df_merged$study)
common_colnames <- c(
  "sex","age","cancer_type","histo","tissueid","treatmentid","stage","recist","response","treatment",
  "survival_time_pfs","event_occurred_pfs","survival_time_os","event_occurred_os"
)

### Available coldata heatmap ###
df_metadata <- data.frame(
  matrix(
    NA, 
    length(common_colnames), 
    length(studies), 
    dimnames=list(common_colnames, studies)
  ), 
  stringsAsFactors=F
)

for(study in studies){
  study_df <- df_merged[df_merged$study == study, ]
  df_metadata[, study] <- unlist(lapply(common_colnames, function(col_name){
    val <- sum(!is.na(study_df[, col_name]))
    pct <- NA
    if(val > 0){
      pct <- (val / length(df_merged$study[df_merged$study == study])) * 100
    }
    return(pct)
  }))
}

pheatmap(
  df_metadata, 
  cluster_rows=FALSE, 
  cluster_cols=FALSE, 
  cellheight=10, 
  na_col = '#ffffff',
  color=colorRampPalette(c("red", "blue"))(50)
)


### Common genes heatmap ###
df_expr_merged <- read.table(file=file.path(input_dir, 'merged_expr.tsv'), header = TRUE, sep = '\t')
all.features <- list()
for(study in studies){
  patients <- rownames(df_merged[df_merged$study == study, ])
  expr <- df_expr_merged[, colnames(df_expr_merged)[colnames(df_expr_merged) %in% patients]]
  expr <- expr[rowSums(!is.na(expr)) > 0, ]
  all.features[[study]] <- rownames(expr)
}

excluded_studies <- c('Hwang', 'Jerby_Arnon', 'Roh') # small number of common genes
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

pheatmap(heatmap.table, color = viridis(30))


### pie chart for patient and gene availability (depth and breadth) ###
studies_to_remove <- c('Puch', 'Shiuan', 'Liu', 'Padron', 'VanDenEnde', 'Snyder')

available_studies <- df_merged[!df_merged$study %in% excluded_studies, ]
all_patients <- length(rownames(available_studies))
all_genes <- range(overlapping_genes_table)[2]

available_studies <- available_studies[!available_studies$study %in% studies_to_remove, ]
available_patients <- length(rownames(available_studies))

overlapping_genes <- overlapping_genes_table[
  !rownames(overlapping_genes_table) %in% studies_to_remove, 
  !colnames(overlapping_genes_table) %in% studies_to_remove
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
