
getPatientGeneNumberTable <- function(studies, df_metadata, all.features){
  table_df <- data.frame(matrix(nrow=length(all.features), ncol=3))
  colnames(table_df) <- c('study', 'num_patients', 'num_genes')
  table_df$study <- names(all.features)
  table_df$num_patients <- unlist(lapply(studies, function(study){
    patients <- df_metadata[df_metadata$study == study, c('patientid')]
    return(length(patients))
  }))
  table_df$num_genes <- unlist(lapply(names(all.features), function(name){
    length(all.features[[name]])
  }))
  return(table_df)
}