# Script to 
# 1. Fetch download links from ORCESTRA's API,
# 2. Download RDS data objects from Zenodo,
# 3. Extract all he data and parse them into TSV files, and
# 4. Compress them into a zip file.

options(timeout=600)

library(stringr)
library(data.table)
library(jsonlite)

# Directory to download RDS files and create zip files.
input_dir <- '~/Data/RDS'
output_dir <- '~/Data/TSV' 

# Get data object info from ORCESTRA and download the latest RDS data objects from Zenodo.
icb_objects <- fromJSON(txt='https://www.orcestra.ca/api/clinical_icb/canonical')
for(obj_name in icb_objects$name){
  link <- icb_objects$downloadLink[icb_objects$name == obj_name]
  filename <- paste0(obj_name, '.rds')
  download.file(url=link, destfile=file.path(input_dir, filename))
}

# For each data object, extract metadata, assay data and gene metadata, parse the data into TSV files, and compress them into a Zip file.
assay_names <- c(
  'expr',
  'expr_gene_tpm',
  'expr_gene_counts',
  'expr_isoform_tpm',
  'expr_isoform_counts'
)

objects <- list.files(input_dir)

for(file in objects){
  obj_name <- str_extract(file, '.*(?=.rds)')
  obj <- readRDS(file.path(input_dir, file))
  dir.create(file.path(output_dir, obj_name))
  coldata <- data.frame(colData(obj))
  write.table(
    coldata, 
    file=file.path(output_dir, obj_name, paste0(obj_name, '_metadata', '.tsv')), 
    sep='\t',
    col.names=TRUE, 
    row.names=TRUE
  )
  
  for(assay_name in assay_names){
    experiment <- experiments(obj)[[assay_name]]
    if(!is.null(experiment)){
      assay <- data.frame(assay(experiment))
      assay_genes <- NA
      if(str_detect(assay_name, 'snv')){
        assay_genes <- data.frame(elementMetadata(experiment))
      }else{
        assay_genes <- data.frame(rowRanges(experiment))
      }
      write.table(
        assay, 
        file=file.path(output_dir, obj_name, paste0(obj_name, '_', assay_name, '.tsv')),  
        sep='\t',
        col.names=TRUE, 
        row.names=TRUE
      )
      write.table(
        assay_genes, 
        file=file.path(output_dir, obj_name, paste0(obj_name, '_', assay_name, '_genes.tsv')),  
        sep='\t',
        col.names=TRUE, 
        row.names=TRUE
      )
    }
  }
  
  zip(
    zipfile=file.path(output_dir, paste0(obj_name, '.zip')), 
    files=list.files(file.path(output_dir, obj_name), full.names = TRUE),
    flags = '-r9Xj'
  )
  
  unlink(file.path(output_dir, obj_name), recursive=TRUE)
}