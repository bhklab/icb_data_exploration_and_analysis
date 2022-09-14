library(rstudioapi)
library(pivottabler)
library(data.table)
library(stringr)

app_dir <- str_split(rstudioapi::getActiveDocumentContext()$path, 'icb_data_exploration_and_analysis')[[1]][1]
app_dir <- paste0(app_dir, 'icb_data_exploration_and_analysis')
setwd(app_dir)

dataset_names <- list.dirs('.local_data', full.names = FALSE)
dataset_names <- dataset_names[dataset_names != ""]

study_colnames <- list()
for(study in dataset_names){
  study_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_metadata.tsv')), sep='\t')
  study_colnames[[study]] <- colnames(study_df)
}

common_colnames <- Reduce(intersect, study_colnames)
# common_colnames <- common_colnames[!common_colnames %in% c("TMB_raw", "nsTMB_raw", "indel_TMB_raw", "indel_nsTMB_raw", "TMB_perMb", "nsTMB_perMb", "indel_TMB_perMb", "indel_nsTMB_perMb", "CIN", "CNA_tot", "AMP", "DEL")]
df_merged <- data.frame(matrix(NA, 0, length(c('study', common_colnames)), dimnames=list(c(), c('study', common_colnames))), stringsAsFactors=F)
total_rows <- 0

df_merged <- data.frame(matrix(NA, 0, length(c('study', common_colnames)), dimnames=list(c(), c('study', common_colnames))), stringsAsFactors=F)
df_metadata <- data.frame(matrix(NA, length(common_colnames), length(dataset_names), dimnames=list(common_colnames, dataset_names)), stringsAsFactors=F)
df_num_genes <- data.frame(matrix(NA, length(dataset_names), 2, dimnames=list(dataset_names, c('num_patients', 'num_genes'))), stringsAsFactors=F)
for(study in dataset_names){
  study_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_metadata.tsv')), sep='\t')
  study_df <- study_df[, common_colnames]
  study_df <- cbind(study = study, study_df)
  
  expr_df <- NA
  if(file.exists(file.path(app_dir, '.local_data', study, paste0(study, '_expr.tsv')))){
    expr_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_expr.tsv')), sep='\t')
  }else{
    expr_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_expr_gene_tpm.tsv')), sep='\t') 
  }
  
  study_df <- study_df[rownames(study_df) %in% colnames(expr_df), ]
  total_rows <- total_rows + nrow(study_df)
  df_merged <- rbind(df_merged, study_df)
  
  df_metadata[, study] <- unlist(lapply(common_colnames, function(col_name){
    sum(!is.na(study_df[, col_name]))
  }))

  df_num_genes[study, 'num_patients'] <- ncol(expr_df)
  df_num_genes[ study, 'num_genes'] = nrow(expr_df)
}

pt <- PivotTable$new()
pt$addData(df_merged)
pt$addColumnDataGroups("response")
pt$addRowDataGroups("study", addTotal=FALSE)
pt$addRowDataGroups("cancer_type", addTotal=FALSE)
pt$defineCalculation(calculationName="TotalPatients", summariseExpression="n()")
pt$renderPivot()

write.table(df_merged, './Data/all_metadata.tsv', sep='\t')
write.table(df_metadata, './Data/metadata_breakdown.tsv', sep='\t')
write.table(df_num_genes, './Data/study_num_genes.tsv', sep='\t')