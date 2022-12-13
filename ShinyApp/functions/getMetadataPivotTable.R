library(pivottabler)

getMetadataPivotTable <- function(columns, cancer_type, treatment){
  table_df <- df_metadata
  
  if(length(cancer_type) > 0){
    table_df <- table_df[table_df$cancer_type %in% cancer_type, ]
  }
  
  if(length(treatment) > 0){
    table_df <- table_df[table_df$treatment %in% treatment, ]
  }
  
  pt <- PivotTable$new()
  pt$addData(table_df)
  for(i in 1:length(columns)){
    addTotal <- FALSE
    if(i == 1){
      addTotal <- TRUE
    }
    pt$addRowDataGroups(columns[i], addTotal=addTotal)
  }
  pt$defineCalculation(calculationName="Total", summariseExpression="n()")
  pt$evaluatePivot()
  pt <- pivottabler(pt)
  return(pt)
}