ref_dir <- '~/Data/genome_ref'

# Get genome references
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
genes_v19 <- order(unique(features_gene_v19$gene_id))
genes_v40 <- order(unique(features_gene_v40$gene_id))

