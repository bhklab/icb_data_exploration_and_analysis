library(rstudioapi)
library(data.table)

app_dir <- str_split(rstudioapi::getActiveDocumentContext()$path, 'icb_data_exploration_and_analysis')[[1]][1]
app_dir <- paste0(app_dir, 'icb_data_exploration_and_analysis')
setwd(app_dir)

dataset_names <- list.dirs('.local_data', full.names = FALSE)
dataset_names <- dataset_names[dataset_names != ""]


all_colnames <- c()
for(study in dataset_names){
  study_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_metadata.tsv')), sep='\t')
  all_colnames <- c(all_colnames, colnames(study_df))
}

all_colnames <- unique(all_colnames)

heatmap_data <- list()
for(study in dataset_names){
  study_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_metadata.tsv')), sep='\t')
  lapply(all_colnames, function(col_name){
    
  })
}


tissues <- c()
for(study in dataset_names){
  study_df <- read.csv(file.path(app_dir, '.local_data', study, paste0(study, '_metadata.tsv')), sep='\t')
  tissues <- c(tissues, study_df$cancer_type)
}
tissues <- unique(tissues)