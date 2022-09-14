library(stringr)

load('Data/Gencode.v19.annotation.RData')
features_gene_v19 <- features_gene

load('Data/Gencode.v40.annotation.RData')
features_gene_v40 <- features_gene

genes_v19 <- rownames(features_gene_v19)
genes_v40 <- rownames(features_gene_v40)

length(intersect(genes_v40, genes_v19)) # identical: 25545

genes_v19_no_version <- str_replace_all(genes_v19, '\\.*', '')
genes_v40_no_version <- str_replace_all(genes_v40, '\\.*', '')
length(intersect(genes_v40_no_version, genes_v19_no_version)) #25545