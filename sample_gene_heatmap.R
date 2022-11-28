library(pheatmap)
library(MultiAssayExperiment)
library(viridis)

mae.list <- list()
mae_files <- list.files('~/Data/RDS/')
mae_files <- mae_files[!mae_files %in% c('ICB_Hwang.rds', 'ICB_Jerby_Arnon.rds', 'ICB_Roh.rds')]
for(mae in mae_files){
  mae.list[mae] <- readRDS(file.path('~/Data/RDS', mae))
}

# identify shared features across 16 studies

temp.features <- list()

for (i in 1:length(mae.list)) {
  temp.names <- names(assays(mae.list[[i]]))
  if ("expr" %in% temp.names) { 
    temp.expr <- MultiAssayExperiment::assays(mae.list[[i]])[["expr"]]  
  }else { 
    temp.expr <- MultiAssayExperiment::assays(mae.list[[i]])[["expr_gene_tpm"]] 
  }
  # fetch features
  temp.features[[i]] <- rownames(temp.expr)
  names(temp.features)[i] <- names(mae.list)[i]
}

lapply(temp.features,head) # everything looks good!

temp <- unlist(temp.features)
temp <- unique(temp) # this is the 93819 features Jonas reported

i=1
temp <- temp.features[[i]]
for (i in 2:16) {
  temp <- base::intersect(temp,temp.features[[i]])
}

temp.table <- matrix(nrow=16,ncol=16)
for (i in 1:16) {
  for (j in 1:16) {
    temp.table[i,j] <- length(base::intersect(temp.features[[i]],temp.features[[j]]))
  }
}

colnames(temp.table) <- names(temp.features)
rownames(temp.table) <- names(temp.features)

pheatmap(temp.table, color = viridis(30))

range(temp.table) # 160 61544
pheatmap(log10(temp.table), color = viridis(30))

rownames(temp.table)
colnames(temp.table)
pheatmap(log10(temp.table[-11,-11]), color = viridis(30))
range(temp.table[-11,-11])

### datasets to exclude: ICB_Puch,ICB_Shiuan,ICB_Liu,ICB_Mariathasan,ICB_Padron,
### but ICB_Mariathasan is the 2nd largest data :( --> let's keep that one
pheatmap(log10(temp.table[-c(11,13,6,10),-c(11,13,6,10)]), color = viridis(30))
range(temp.table[-c(11,13,6,10),-c(11,13,6,10)])

# and if is also excluded
pheatmap(log10(temp.table[-c(11,13,6,10,7),-c(11,13,6,10,7)]), color = viridis(30))
range(temp.table[-c(11,13,6,10,7),-c(11,13,6,10,7)])

### after discussion within the team, we go for 2 options:

# option 1: larger feature space, smaller N
# option 2: smaller feature space, larger N