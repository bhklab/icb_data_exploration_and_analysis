library(rstudioapi)
library(stringr)
library(pivottabler)
library(data.table)
library(plotly)
library(pheatmap)
library(viridis)

app_dir <- str_split(rstudioapi::getActiveDocumentContext()$path, 'icb_data_exploration_and_analysis')[[1]][1]
app_dir <- paste0(app_dir, 'icb_data_exploration_and_analysis')
setwd(app_dir)

dataset_names <- list.dirs(file.path(app_dir, '.local_data'), full.names = FALSE, recursive = FALSE)

study_colnames <- list()
for(study in dataset_names){
  study_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_metadata.tsv')), sep='\t')
  study_colnames[[study]] <- colnames(study_df)
}

common_colnames <- Reduce(intersect, study_colnames)
common_colnames <- c(common_colnames, c('Treatment.regimen', 'Drug.targets', 'Metastasis.status', 'Monotherapy', 'Combination'))
# common_colnames <- common_colnames[!common_colnames %in% c("TMB_raw", "nsTMB_raw", "indel_TMB_raw", "indel_nsTMB_raw", "TMB_perMb", "nsTMB_perMb", "indel_TMB_perMb", "indel_nsTMB_perMb", "CIN", "CNA_tot", "AMP", "DEL")]
# df_merged <- data.frame(matrix(NA, 0, length(c('study', common_colnames)), dimnames=list(c(), c('study', common_colnames))), stringsAsFactors=F)
df_merged <- read.csv(file.path(app_dir, 'Data', 'all_metadata.tsv'), sep='\t')
total_rows <- 0

df_metadata <- data.frame(matrix(NA, length(common_colnames), length(dataset_names), dimnames=list(common_colnames, dataset_names)), stringsAsFactors=F)
df_num_genes <- data.frame(matrix(NA, length(dataset_names), 2, dimnames=list(dataset_names, c('num_patients', 'num_genes'))), stringsAsFactors=F)

all.features <- list()
for(study in dataset_names){
  study_df <- df_merged[df_merged$study == study, ]
  study_df <- cbind(study = study, study_df)
  
  expr_df <- NA
  if(file.exists(file.path(app_dir, '.local_data', study, paste0(study, '_expr.tsv')))){
    expr_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_expr.tsv')), sep='\t')
  }else{
    expr_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_expr_gene_tpm.tsv')), sep='\t') 
  }
  all.features[[study]] <- rownames(expr_df)
  
  df_metadata[, study] <- unlist(lapply(common_colnames, function(col_name){
    sum(!is.na(study_df[, col_name]))
  }))
  
  df_num_genes[study, 'num_patients'] <- ncol(expr_df)
  df_num_genes[ study, 'num_genes'] = nrow(expr_df)
}

df_num_genes <- df_num_genes[order(df_num_genes$num_genes, decreasing = TRUE), ]
write.table(df_num_genes, file='~/Data/num_genes.csv')

matrix_metadata <- df_metadata
excluded_metadata <- c('patientid', 'treatmentid', 'dna', 'rna', 'Monotherapy')
included_metadata <- rownames(matrix_metadata)[!rownames(matrix_metadata) %in% excluded_metadata]
excluded_datasets <- c()
matrix_metadata <- matrix_metadata[included_metadata, !colnames(matrix_metadata) %in% excluded_datasets]
matrix_metadata[matrix_metadata == 0] <- NA

for(dataset in dataset_names){
  matrix_metadata[, dataset] <- unlist(lapply(matrix_metadata[, dataset], function(val){
    pct <- val
    if(!is.na(val)){
      pct <- (val / length(df_merged$study[df_merged$study == dataset])) * 100
    }
    return(pct)
  }))
}

pheatmap(
  matrix_metadata, 
  cluster_rows=FALSE, 
  cluster_cols=FALSE, 
  cellheight=10, 
  na_col = '#ffffff',
  color=colorRampPalette(c("red", "blue"))(50)
)


pt <- PivotTable$new()
pt$addData(df_merged)
pt$addColumnDataGroups("response")
pt$addRowDataGroups("study", addTotal=FALSE)
pt$addRowDataGroups("cancer_type", addTotal=FALSE)
pt$addRowDataGroups("Drug.targets", addTotal=FALSE)
pt$addRowDataGroups("Metastasis.status", addTotal=FALSE)
pt$addRowDataGroups("Monotherapy", addTotal=FALSE)
pt$addRowDataGroups("Combination", addTotal=FALSE)
pt$defineCalculation(calculationName="TotalPatients", summariseExpression="n()")
pt$renderPivot()


excluded_datasets <- c('ICB_Hwang', 'ICB_Jerby_Arnon', 'ICB_Roh')
dataset_names_common_genes <- dataset_names[!dataset_names %in% excluded_datasets]
temp.features <- all.features[names(all.features)[!names(all.features) %in% excluded_datasets]]

lapply(temp.features,head) # everything looks good!

temp <- unlist(temp.features)
temp <- unique(temp) # this is the 93819 features Jonas reported

num_datasets <- length(dataset_names_common_genes)
i=1
for (i in 2:num_datasets) {
  temp <- base::intersect(temp,temp.features[[i]])
}

temp.table <- matrix(nrow=num_datasets, ncol=num_datasets)
for (i in 1:num_datasets) {
  for (j in 1:num_datasets) {
    temp.table[i,j] <- length(base::intersect(temp.features[[i]],temp.features[[j]]))
  }
}

colnames(temp.table) <- names(temp.features)
rownames(temp.table) <- names(temp.features)

range(temp.table) # 160 61544

temp.table <- (temp.table / all_genes) * 100

pheatmap(log10(temp.table), color = viridis(30))


datasets_to_remove <- c('ICB_Puch', 'ICB_Shiuan', 'ICB_Liu', 'ICB_Padron', 'ICB_Mariathasan')
# datasets_to_remove <- c()

available_datasets <- df_merged[!df_merged$study %in% excluded_datasets, ]
all_patients <- length(rownames(available_datasets))
all_genes <- range(temp.table)[2]

available_datasets <- available_datasets[!available_datasets$study %in% datasets_to_remove, ]
available_patients <- length(rownames(available_datasets))

overlapping_genes <- temp.table[!rownames(temp.table) %in% datasets_to_remove, !colnames(temp.table) %in% datasets_to_remove]
available_genes <- range(overlapping_genes)[1]

colors <- c('#FF7F0E', '#c6c6c6')
available_patients_pct <- (available_patients/all_patients) * 100
patients <- data.frame(
  availability=c('available', 'unavailable'), 
  percentage=c(available_patients_pct, 100 - available_patients_pct)
)
pie_patients <- plot_ly(
  patients, 
  labels = ~availability, 
  values = ~percentage, 
  marker = list(colors = colors),
  type = 'pie',
  textfont = list(size = 40)
)
pie_patients <- pie_patients %>% layout(title = '',
                                        xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                        legend = list(font = list(size = 20)))

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
