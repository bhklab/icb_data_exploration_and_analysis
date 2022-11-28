library(stringr)
library(data.table)

load('Data/Gencode.v19.annotation.RData')
features_gene_v19 <- features_gene

load('Data/Gencode.v40.annotation.RData')
features_gene_v40 <- features_gene

genes_v19 <- order(unique(features_gene_v19$gene_id))
genes_v40 <- order(unique(features_gene_v40$gene_id))

length(intersect(genes_v40, genes_v19)) # identical: 57820
length(genes_v40[genes_v40 %in% genes_v19])

genes_v19_no_version <- str_replace_all(genes_v19, '\\.*', '')
genes_v40_no_version <- str_replace_all(genes_v40, '\\.*', '')
length(intersect(genes_v40_no_version, genes_v19_no_version)) #25545

write.table(intersect(genes_v40, genes_v19), 'Data/common_genes.txt', col.names=FALSE, row.names = FALSE, quote=FALSE)