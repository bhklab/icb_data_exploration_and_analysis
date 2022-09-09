options(timeout=600)

library(jsonlite)
library(stringr)
library(rstudioapi) 

# Script to download and extract TSV version of ICB data from Zenodo
zenodo_repo <- 'https://zenodo.org/record/7058399/files/'
studies <- c() # empty or specify studies to download. exmaple: ICB_Braun, ICB_Gide...

# Create directory to download the datasets
app_dir <- str_split(rstudioapi::getActiveDocumentContext()$path, 'Code')[[1]]
setwd(app_dir)
dir.create('./local_data', showWarnings = FALSE)
dir <- './local_data'

filenames <- c()
# if no studies are specified, get available data object names from ORCESTRA
if(length(studies) == 0){
  icb_objects <- fromJSON(txt='https://www.orcestra.ca/api/clinical_icb/canonical')
  filenames <- lapply(icb_objects$name, function(name){
    return(paste0(name, '.zip'))
  })
}else{
  filenames <- lapply(studies, function(study){
    return(paste0(study, '.zip'))
  })
}

# download zip files all specified (or all) studies
filenames <- unlist(filenames)
for(filename in filenames){
  download.file(paste0(zenodo_repo, filename, '?download=1'), destfile=file.path(dir, filename))
  dir.create(path=file.path(dir, str_replace(filename, '.zip', '')))
  unzip(zipfile = file.path(dir, filename), exdir=file.path(dir, str_replace(filename, '.zip', '')))
  file.remove(file.path(dir, filename))
}