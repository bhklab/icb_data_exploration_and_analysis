library(rstudioapi)
library(pivottabler)
library(data.table)
library(stringr)

app_dir <- str_split(rstudioapi::getActiveDocumentContext()$path, 'icb_data_exploration_and_analysis')[[1]][1]
app_dir <- paste0(app_dir, 'icb_data_exploration_and_analysis')
setwd(app_dir)

dataset_names <- list.dirs('.local_data', full.names = FALSE)
dataset_names <- dataset_names[dataset_names != ""]

df_merged <- data.frame(matrix(NA, 0, length(c('study', common_colnames)), dimnames=list(c(), c('study', common_colnames))), stringsAsFactors=F)
for(study in dataset_names){
  study_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_metadata.tsv')), sep='\t')
  study_colnames[[study]] <- colnames(study_df)
}