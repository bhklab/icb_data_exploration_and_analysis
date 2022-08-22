# Immune-checkpoint blockade (ICB) data analysis

This repo contains code associated with the PredictIO signature computation along with the preliminary analyses (R and Python) using the Immune-checkpoint blockade (ICB) data.

## Data

The data associated with this analysis is available from ....

## Organization of repo

The code can be organized into downloading data, preliminary analyses, and PredictIO signature computation scripts. 

### Download data

rds_to_tsv.R: Fetch download links from ORCESTRA's API. Download RDS data objects from Zenodo. Extract all the data and parse them into TSV files, and compress them into a zip file.

### Preliminary 

#### Part 1: 

Preliminary-Analyses.Rmd/Preliminary-Analyses.ipynb: Contains the descriptive statistics analyses, logistic regression model, and survival analyses including the Kaplan-Meier, log-rank test, and Cox regression. Note that only Braun (PMID 32472114) is applied. 

#### Part 2: 

Meta-analyses.Rmd/Meta-analyses.ipynb: Consider the ICB studies including Braun (PMID 32472114), Nathanson (PMID 27956380), Snyder (PMID 28552987), and Van Allen (PMID 26359337). For a given gene across studies, we do the following steps 

(1) Fit Cox model to assess the association between the gene expression and overall survival (OS) outcome.

(2) Integrate the association of a gene with ICB response (i.e., logHR) and their variances across studies using the random effect (RE) meta-analysis approach where the DerSimonian and Laird (DL) is applied to estimate the heterogeneity across studies. 

### PredictIO signature

meta: Include the scripts to integrate the association of the genes with ICB response across ICB studies using the meta-analyses, Egger test, and subgroup analyses along with the visualization plots such as forest plot and funnel plot. 

preprocess.R: Convert the MultiAssayExperiment object data into ExpressionSet object for the PredictIO signature analyses using RDS files. 

denovo_Single_Gene/run_denovo_SG.R: Contain the meta-analysis of the association of these genes with ICB response such as OS, PFS, and response. 

PredictIO/run_PredictIO.R: Include the PredictIO signature computation scripts using the top genes significantly associated with ICB response.


PredictIO_Validation/run_PredictIO.R: Include the scripts to validate the PredictIO signature derived from the de novo pan-cancer analysis.




