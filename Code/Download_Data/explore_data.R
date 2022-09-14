library(rstudioapi)
library(pivottabler)
library(data.table)

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
for(study in dataset_names){
  study_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_metadata.tsv')), sep='\t')
  study_df <- study_df[, common_colnames]
  study_df <- cbind(study = study, study_df)
  total_rows <- total_rows + nrow(study_df)
  df_merged <- rbind(df_merged, study_df)
}

pt <- PivotTable$new()
pt$addData(df_merged)
pt$addColumnDataGroups("response")
pt$addRowDataGroups("study", addTotal=FALSE)
pt$addRowDataGroups("sex", addTotal=FALSE)
pt$addRowDataGroups("tissueid", addTotal=FALSE)
pt$addRowDataGroups("treatmentid", addTotal=FALSE)
pt$defineCalculation(calculationName="TotalPatients", summariseExpression="n()")
pt$renderPivot()