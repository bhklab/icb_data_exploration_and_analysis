library(pheatmap)

getMetadataHeatmap <- function(df_metadata, studies){
  common_colnames <- c(
    "sex","age","cancer_type","histo","tissueid","treatmentid","stage","recist","response","treatment",
    "survival_time_pfs","event_occurred_pfs","survival_time_os","event_occurred_os", "survival_type", "TMB_raw"
  )
  df_heatmap <- data.frame(
    matrix(
      NA, 
      length(common_colnames), 
      length(studies), 
      dimnames=list(common_colnames, studies)
    ), 
    stringsAsFactors=F
  )
  
  for(study in studies){
    study_df <- df_metadata[df_metadata$study == study, ]
    df_heatmap[, study] <- unlist(lapply(common_colnames, function(col_name){
      val <- sum(!is.na(study_df[, col_name]))
      pct <- NA
      if(val > 0){
        pct <- (val / length(df_metadata$study[df_metadata$study == study])) * 100
      }
      return(pct)
    }))
  }
  return(
    pheatmap(
      df_heatmap, 
      cluster_rows=FALSE, 
      cluster_cols=FALSE, 
      cellheight=10, 
      na_col = '#ffffff',
      color=colorRampPalette(c("red", "blue"))(50)
    )
  )
}