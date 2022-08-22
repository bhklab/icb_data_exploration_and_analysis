## Packages

library(Biobase)
library(PharmacoGx)
library(matrixcalc)
library(ggplot2)

############################################################################
## convert MultiAssayExperiment obj curated data into ExpressionSet obj
############################################################################
## Consider the RDS downloaded data

dir0 <- "~/Data/RDS"
dat_files <- list.files(dir0)[-1]
dat_files_no_exp <- dat_files[!(dat_files %in% c("ICB_Miao2.rds", "ICB_Rizvi15.rds",
                                          "ICB_Rizvi18.rds", "ICB_Roh.rds",
                                          "ICB_Samstein.rds"))]

dat_files_rawrnaseq <- c("ICB_Gide.rds", "ICB_Hugo.rds", "ICB_Jung.rds", "ICB_Kim.rds", "ICB_Riaz.rds")
dat_files_no_rawrnaseq <- dat_files_no_exp[!(dat_files_no_exp %in% dat_files_rawrnaseq)]

expr_no_rawrnaseq <- lapply(1:length(dat_files_no_rawrnaseq), function(k){
  
  print(k)
  dir <- paste(dir0, dat_files_no_rawrnaseq[k], sep="/")
  dat <- readRDS(dir)
  
  dat_exp <- assay(dat@ExperimentList$expr) 
  dat_exp <- dat_exp[order(rownames(dat_exp)), ]
  dat_clinic <- data.frame(colData(dat)) 
  dat_clinic  <- dat_clinic[order(rownames(dat_clinic )), ]
  dat_gene <- data.frame(rowData(dat@ExperimentList$expr))
  
  dat_exp <- dat_exp[, order(colnames(dat_exp))]
  
  int <- intersect(colnames(dat_exp), rownames(dat_clinic))
  dat_clinic <- dat_clinic[rownames(dat_clinic) %in% int, ]
  
  eset <- ExpressionSet(assayData = as.matrix(dat_exp),
                        phenoData = AnnotatedDataFrame(dat_clinic))
  eset		
  
})
  
names(expr_no_rawrnaseq) <- substr(dat_files_no_rawrnaseq, 5, nchar(dat_files_no_rawrnaseq) - 4)


dat_files_rawrnaseq <- c("ICB_Gide.rds", "ICB_Hugo.rds", "ICB_Jung.rds", "ICB_Kim.rds", "ICB_Riaz.rds")

expr_rawrnaseq <- lapply(1:length(dat_files_rawrnaseq), function(k){
  
  print(k)
  dir <- paste(dir0, dat_files_rawrnaseq[k], sep="/")
  dat <- readRDS(dir)
  
  dat_exp <- assay(dat@ExperimentList$expr_gene_tpm) 
  dat_exp <- dat_exp[order(rownames(dat_exp)), ]
  dat_clinic <- data.frame(colData(dat@ExperimentList$expr_gene_tpm)) 
  dat_clinic  <- dat_clinic[order(rownames(dat_clinic )), ]
  dat_gene <- data.frame(rowData(dat@ExperimentList$expr_gene_tpm))
  
  dat_exp <- dat_exp[, order(colnames(dat_exp))]
  
  int <- intersect(colnames(dat_exp), rownames(dat_clinic))
  dat_clinic <- dat_clinic[rownames(dat_clinic) %in% int, ]
  
  eset <- ExpressionSet(assayData = as.matrix(dat_exp),
                        phenoData = AnnotatedDataFrame(dat_clinic))
  eset		
  
})

names(expr_rawrnaseq) <- substr(dat_files_rawrnaseq, 5, nchar(dat_files_rawrnaseq) - 4)

expr <- c(expr_no_rawrnaseq, expr_rawrnaseq)
save(expr, file= "~/Result/ICB_exp.RData")


#########################################################################################################
## Remove the validation cohort from the ICB ExpressionSet objects and only keep discovery cohort data
#########################################################################################################

load("~/Result/ICB_exp.RData")

study = names(expr)
study = study[!(study %in% c("Padron", "Puch", "Shiuan", "VanDenEnde", "Kim", "Gide"))]
study 

expr <- expr[study]


save(expr, file="~/Result/ICB_exp_filtered.RData")

##########################################
## save validation cohorts as RData files
##########################################

load("~/Result/ICB_exp.RData")

study = names(expr)
study = study[(study %in% c("Padron", "Puch", "Shiuan", "VanDenEnde", "Kim", "Gide"))]
study 

valid_expr <- expr

dir0 <- "~/Data/validation_cohort/"

for(i in 1:length(study)){
  
  expr <- valid_expr[study[i]][[1]]@assayData$exprs
  clin <- valid_expr[study[i]][[1]]@phenoData@data
  
  save(expr, clin, file=paste(dir0, paste(study[i], ".RData", sep=""), sep=""))
}



