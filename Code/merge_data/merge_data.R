# Script to 
# 1. Fetch download links from ORCESTRA's API,
# 2. Download RDS data objects from Zenodo,
# 3. Extract clinical and gene expression data (TPM).
# 4. Merge all the data into one file (one for clinical data and another for expr TPM data)

options(timeout=1000)

library(stringr)
library(data.table)
library(jsonlite)

# Directory to download RDS files and create zip files.
input_dir <- '~/Data/RDS'
output_dir <- '~/Data/TSV'
ref_dir <- '~/Data/genome_ref'
merged_dir <- '~/Data/merged'

# Get data object info from ORCESTRA and download the latest RDS data objects from Zenodo.
icb_objects <- fromJSON(txt='https://www.orcestra.ca/api/clinical_icb/canonical')
for(obj_name in icb_objects$name){
  link <- icb_objects$downloadLink[icb_objects$name == obj_name]
  filename <- paste0(obj_name, '.rds')
  if(!file.exists(file.path(input_dir, filename))){
    download.file(url=link, destfile=file.path(input_dir, filename))
  }
}

objects <- list.files(input_dir)
coldata_list <- list()
cols_list <- list()
expr_list <- list()
for(file in objects){
  print(file)
  obj_name <- str_extract(file, '.*(?=.rds)')
  obj <- readRDS(file.path(input_dir, file))
  coldata <- data.frame(colData(obj))
  
  experiment <- NA
  if(!is.null(experiments(obj)[['expr']])){
    experiment <- experiments(obj)[['expr']]
  }else{
    experiment <- experiments(obj)[['expr_gene_tpm']]
  }
  experiment_df <- data.frame(assay(experiment))
  coldata <- coldata[rownames(coldata) %in% colnames(experiment_df), ]
  coldata_list[[obj_name]] <- coldata
  cols_list[[obj_name]] <- colnames(coldata)
  expr_list[[obj_name]] <- experiment_df
  print(range(experiment_df))
}

objects <- str_replace(objects, '.rds', '')
common_cols <- c()
for(obj in objects){
  if(length(common_cols) == 0){
    common_cols <- cols_list[[obj]]
  }else{
    common_cols <- intersect(common_cols, cols_list[[obj]])
  }
}

merged_metadata <- data.frame(matrix(nrow=0, ncol=length(common_cols) + 1))
colnames(merged_metadata) <- c(common_cols, 'study')
for(obj in objects){
  coldata <- coldata_list[[obj]][, common_cols]
  dataset_name <- str_replace(obj, 'ICB_', '')
  coldata$study <- dataset_name
  unique_id <- paste0(rownames(coldata), '_', dataset_name)
  rownames(coldata) <- unique_id
  coldata$patientid <- unique_id
  merged_metadata <- rbind(merged_metadata, coldata)
}

write.table(
  merged_metadata, 
  file=file.path(merged_dir, 'merged_metadata.tsv'), 
  sep='\t',
  col.names=TRUE, 
  row.names=TRUE
)

# Merge expression data
# Download genome references
download.file(
  url='https://github.com/BHKLAB-DataProcessing/Annotations/raw/master/Gencode.v19.annotation.RData',
  destfile=file.path(ref_dir, 'Gencode.v19.annotation.RData')
)
download.file(
  url='https://github.com/BHKLAB-DataProcessing/Annotations/raw/master/Gencode.v40.annotation.RData',
  destfile=file.path(ref_dir, 'Gencode.v40.annotation.RData')
)

load(file.path(ref_dir, 'Gencode.v19.annotation.RData'))
features_gene_v19 <- features_gene
load(file.path(ref_dir, 'Gencode.v40.annotation.RData'))
features_gene_v40 <- features_gene

genes_v19 <- features_gene_v19$gene_id
genes_v40 <- features_gene_v40$gene_id

# genes_v19 <- str_replace(genes_v19$gene_id, '\\.[0-9]+', '')
# genes_v40 <- str_replace(genes_v40$gene_id, '\\.[0-9]+', '')

common_genes <- intersect(genes_v40, genes_v19)
common_genes_df <- features_gene_v40[features_gene_v40$gene_id %in% as.character(common_genes), ]
common_genes_df$gene_id_no_ver <- str_replace(common_genes_df$gene_id, '\\.[0-9]+', '')

merged_expr <- data.frame(matrix(
  nrow=length(rownames(common_genes_df)), 
  ncol=0)
)
rownames(merged_expr) <- common_genes_df$gene_id
merged_expr <- merged_expr[str_order(rownames(merged_expr)), ]
for(obj in objects){
  expr <- expr_list[[obj]]
  # rownames(expr) <- str_replace(rownames(expr), '\\.[0-9]+', '')
  expr <- expr[rownames(expr) %in% common_genes_df$gene_id, ]
  missing <- common_genes_df$gene_id[!common_genes_df$gene_id %in% rownames(expr)]
  missing_df <- data.frame(matrix(nrow=length(missing), ncol=length(colnames(expr))))
  rownames(missing_df) <- missing
  colnames(missing_df) <- colnames(expr)
  expr <- rbind(expr, missing_df)
  expr <- expr[str_order(rownames(expr)), ]
  colnames(expr) <- paste0(colnames(expr), '_', str_replace(obj, 'ICB_', ''))
  merged_expr <- cbind(merged_expr, expr)
}

write.table(
  merged_expr, 
  file=file.path(merged_dir, 'merged_expr.tsv'), 
  sep='\t',
  col.names=TRUE, 
  row.names=TRUE
)

write.table(
  common_genes_df, 
  file=file.path(merged_dir, 'gene_metadata.tsv'), 
  sep='\t',
  col.names=TRUE, 
  row.names=TRUE
)