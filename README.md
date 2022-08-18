# Immune-checkpoint blockade (ICB) data analysis

We include the R and Python codes to doing preliminary analyses and meta-analyses using Immune-checkpoint blockade (ICB) data. 

## Preliminary analysis

The descriptive statistics, logistic regression model, and survival analyses including the  Kaplan-Meier, log-rank test, and Cox regression are considered. Note that only Braun (PMID 32472114) is applied. 

## Meta-analysis

We consider the ICB studies including Braun (PMID 32472114), Nathanson (PMID 27956380), Snyder (PMID 28552987), and Van Allen (PMID 26359337). For a given gene across studies, we do the following steps 

(1) Fit Cox model to assess the association between the gene expression and response outcome (R vs. NR).

(2) Integrate the estimated effect sizes (i.e., logHR) and their variances across studies using the random effect (RE) meta-analysis approach where the DerSimonian and Laird (DL) is applied to estimate the heterogeneity across studies. 
