# Immune-checkpoint blockade (ICB) data analysis

This repo contains code associated with the PredictIO signature computation along with the preliminary analyses (R and Python) using the Immune-checkpoint blockade (ICB) data.

## Data

* The data associated with this analysis is downloaded using ORCESTRA's API. 
* summary_tables.xlsx - (1) Discovery cohorts, (2) Validation cohorts, (3) Signature details (4) GSVA curated signature gene composition and (5) Weigthed-mean curated signature gene composition. 
* Signature - The list of signatures and their details.

## Organization of repo

The code is organized into downloading data, preliminary analyses, and PredictIO signature computation scripts. 

### Download data

A complete workflow starting from accessing data from source to creating MAE and extracting TSV files: ICB_Data_Curation_Example.Rmd

rds_to_tsv.R: Fetch download links from ORCESTRA's API. Download RDS data objects from Zenodo. Extract all the data and parse them into TSV files, and compress them into a zip file.

download_tsv_data.R: Script to download and extract TSV version of ICB data from Zenodo in R.

download_tsv_data.py: Script to download and extract TSV version of ICB data from Zenodo in Python.

### Preliminary 

#### Part 1: 

Preliminary-AnalysIs.Rmd/Preliminary-AnalysIs.ipynb: Contains the descriptive statistics analyses, logistic regression model, and survival analyses including the Kaplan-Meier, log-rank test, and Cox regression. Note that only Braun stuy (PMID 32472114) is applied. 

#### Part 2: 

Meta-analyses.Rmd/Meta-analyses.ipynb: Consider the the subset of ICB studies to assess the association of a given gene with response ICB outcome (R vs NR). For a given gene across studies, we do the following steps 

(1) Fit logistic regression model to assess the association between the gene expression and response outcome (R vs NR).

(2) Integrate the association of a gene with ICB response (i.e., logOR) and their variances across studies using the random effect (RE) meta-analysis approach where the DerSimonian and Laird (DL) is applied to estimate the heterogeneity across studies. 

#### Part 3: 

Meta-Analyses-Genes.Rmd: Consider the the subset of ICB studies to assess the association of with overall survival (OS). For common genes across studies, we do the following steps 

(1) Fit Cox model to assess the association between the gene expression and survival outcome (OS).

(2) Integrate the association of gene with ICB response (i.e., logHR) and their variances across studies using the random effect (RE) meta-analysis approach where the DerSimonian and Laird (DL) is applied to estimate the heterogeneity across studies. 

#### Part 4:

Signature-Analysis-Genes-OS.Rmd: Consider the association between signatures and survival outcome (OS) including following steps:

(1) Compute the signature score using the gene set variation analysis (GSVA).

(2) Fit Cox model to assess the association between the signature and survival outcome (OS).

(3) Integrate the association of signature with ICB response (i.e., logHR) and their variances across studies using the random effect (RE) meta-analysis approach where the DerSimonian and Laird (DL) is applied to estimate the heterogeneity across studies. 

### PredictIO signature

meta: Include the scripts to integrate the association of the genes with ICB response across ICB studies using the meta-analyses, Egger test, and subgroup analyses along with the visualization plots such as forest plot and funnel plot. 

preprocess.R: Convert the MultiAssayExperiment object data into ExpressionSet object for the PredictIO signature analyses using RDS files. 

denovo_Single_Gene/run_denovo_SG.R: Contain the meta-analysis of the association of these genes with ICB response such as OS, PFS, and response. 

PredictIO/run_PredictIO.R: Include the PredictIO signature computation scripts using the top genes significantly associated with ICB response.


PredictIO_Validation/run_PredictIO.R: Include the scripts to validate the PredictIO signature derived from the de novo pan-cancer analysis.




