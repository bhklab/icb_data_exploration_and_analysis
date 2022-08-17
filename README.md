## Immune-checkpoint blockade (ICB) data analyses

We include the R and Python codes to doing preliminary analyses and meta-analyses using Immune-checkpoint blockade (ICB) data. 

To do the preliminary analyses, descriptive statistics, logistic regression model, and survival analyses (Kaplan-Meier, log-rank test, and Cox regression) were considered. Note that only Braun (PMID 32472114) was considered. 

To do the meta-analysis, we considered the four ICB studies including Braun (PMID 32472114), Nathanson (PMID 27956380), Snyder (PMID 28552987), and Van Allen (PMID 26359337). For a given gene across studies 

(1) Fit Cox model to assess the association between gene expression and response outcome (R vs NR).
(2) Integrate the effect sizes (logHR) and their variances using the random effect (RE) meta-analysis approach where the DerSimonian and Laird (DL) is applied to estimate the heterogeneity across studies. 
