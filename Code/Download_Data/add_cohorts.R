# To merge new columns to metadata

all_meta <- read.csv("~/Desktop/icb_data_exploration_and_analysis/Data/all_metadata.tsv", sep = "\t")
#all_meta_sub <- subset(all_meta, subset = !duplicated(all_meta_sub$study), select = c("study"))
#write.csv(all_meta_sub, "~/Downloads/all_meta_sub.csv")

all_clin <- read.csv("~/Desktop/icb_data_exploration_and_analysis/Data/All clinical datasets - Immunotherapy datasets.csv")

all_meta$id  <- 1:nrow(all_meta)
mer_meta_clin <- merge(all_meta, all_clin, by.x = "study", by.y = "Dataset.Name", all.x = TRUE)

mer_meta_clin <- mer_meta_clin[order(mer_meta_clin$id),]

write.table(mer_meta_clin, file = "~/Desktop/icb_data_exploration_and_analysis/Data/all_metadata.tsv", row.names=FALSE, sep="\t")
