# HC3383 - Manuscript 1560 - Association of Preconception Socio-Behavioral Factors and Child Weight in HCHS/SOL

**Project ID:** HC3383  
**Programmer:** Alvaro Quijano-Angarita  
**Created:** 2025-04-23  
**Status:** ongoing

---

## Project Description
This project contains SAS code and outputs for Manuscript 1560, focused on maternal preconception socio-behavioral factors and child weight outcomes in the HCHS/SOL FLOR study.

---

## Scripts Summary
| Code | Task |
|------|------|
| HC338302/HC338302.sas | Generates Table 1 with maternal preconception and child characteristics by FLOR participation. |
| HC338351/HC338351.sas | Creates the analytic datasets used for QC and downstream analyses. |
| HC338352/HC338352.sas | Produces missing data patterns by manuscript domains. |
| HC338353/HC338353.sas | Runs multiple imputation model (n~227 x 10 imputations). |
| HC338353a/HC338353a.sas | Runs multiple imputation model variant (n~201 x 10 imputations). |
| HC338353b/HC338353b.sas | Runs alternate imputation model with PAG2008YN, HEI2010_C3, and SLPDUR_LT8HRS (n~227). |
| HC338353c/HC338353c.sas | Runs alternate imputation model with PAG2008YN, HEI2010_C3, and SLPDUR_LT8HRS (n~201). |
| HC338354/HC338354.sas | Fits regression models and generates Table 2 (n~227). |
| HC338354a/HC338354a.sas | Fits regression models and generates Table 2 for the n~201 analytic sample. |
| HC338354a/HC338354a_20NOV25.sas | Archived/snapshot version of HC338354a used for November 2025 runs. |
| HC338354b/HC338354b.sas | Fits alternate regression models and generates Table 2.1 (n~227). |
| HC338354c/HC338354c.sas | Fits alternate regression models and generates Table 2.1 for n~201 sample. |
| HC338355/HC338355.sas | Produces descriptive/univariate table of individual associations. |
| HC338356a/HC338356a.sas | Performs mediation analysis excluding PRS from the model. |
| HC338356b/HC338356b.sas | Performs mediation analysis including PRS in the model. |
| HC338357/HC338357.sas | Generates inclusion/exclusion flow table. |
| HC338358/HC338358.sas | Fits logistic models and generates Table 3 (response: BMIPCT_C2). |
| HC338358a/HC338358a.sas | Fits logistic models and generates Table 3a for the n~201 sample. |
| HC338390/HC338390.sas | Centralized variable formats used across manuscript scripts. |
| HC338391/HC3383_labels.sas | Defines labels/macros used in reporting workflows (e.g., regression table labels). |
| HC338391/HC3383_mi_lasso.sas | Supports MI model feature selection using lasso-based workflow. |
| HC338391/HC3383_process_imputed.sas | Processes imputed datasets for downstream modeling. |
| HC338391/HC3383_anonymize_db.sas | Applies anonymization/processing utilities to project datasets. |
| HC338391/HC3383_partial_r2.sas | Computes partial R2/sensitivity metrics for model interpretation. |
| HC338398/HC33839801.sas | QC check (Cont #1) for derived analytic files. |
| HC338398/HC33839802.sas | QC check (Cont #2) for derived analytic files. |
| HC338398/HC33839803.sas | Post-QC comparison script after feedback updates. |
| HC338398/HC33839804.sas | Quality check script for Table 1 outputs. |
| HC338398/HC33839805.sas | Computes supplemental frequencies to support manuscript flow chart/QC. |
| HC338399/HC33839901.sas | Creates HEI-2010 tertiles and related summaries. |
| HC338399/HC33839902.sas | Generates correlation analyses for selected covariates. |
| HC338399/HC33839903.sas | Miscellaneous project support analysis (job 9903). |
| HC338399/HC33839904.sas | Miscellaneous project support analysis (job 9904). |

---

**Generated on:** 2026-03-08 using `generate_md.R` by Alvaro Quijano-Angarita
