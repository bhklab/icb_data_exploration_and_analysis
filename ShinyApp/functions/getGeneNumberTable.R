
getGeneNumberTable <- function(all.features){
  num_features_df <- data.frame(matrix(nrow=length(all.features), ncol=2))
  colnames(num_features_df) <- c('study', 'num_genes')
  num_features_df$study <- names(all.features)
  num_features_df$num_genes <- unlist(lapply(names(all.features), function(name){
    length(all.features[[name]])
  }))
  return(num_features_df)
}