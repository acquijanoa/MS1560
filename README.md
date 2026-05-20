# HC3383 - Manuscript 1560 - Association of Preconception Socio-Behavioral Factors and Child Weight in HCHS/SOL

**Project ID:** HC3383  
**Programmer:** Alvaro Quijano-Angarita  
**Created:** 2025-04-23  
**Status:** completed

---

## Project Description
This project contains SAS code and outputs for Manuscript 1560, focused on maternal preconception socio-behavioral factors and child weight outcomes in the HCHS/SOL FLOR study.

---

## Scripts Summary
| Code | Task |
|------|------|
| HC338302/HC338302.sas | Job 02 (adapted from SC HC338302): descriptive Table 1 with maternal preconception and child characteristics. |
| HC338351/HC338351.sas | Job 51: builds FLOR-only and all-eligible analytic datasets for QC. |
| HC338352/HC338352.sas | Job 52: missing-data pattern tables by manuscript domains using the FLOR analytic dataset. |
| HC338353/HC338353.sas | Job 53: multiple imputation (10 imputations, n=227 main sample); output HC338353_imputed_data_<datefile>; waz/bmiz in MI model; raw anthropometry not imputed. |
| HC338353a/HC338353a.sas | Job 53a: MI for the PRS-complete subset (n=201); same covariate logic as job 53 except child anthropometry and child_prs_bmi_a are not imputed. |
| HC338354/HC338354.sas | Job 54: pooled linear model for child WAZ across imputations (Models 1–4); produces Table 2.1 for the main sample. |
| HC338354a/HC338354a.sas | Job 54a: same pooled linear model as job 54 for WAZ on the PRS-complete imputed sample; produces Table 2.1a. |
| HC338358/HC338358.sas | Job 58: pooled logistic model for overweight/obese indicator BMIPCT_C2; produces Table 3. |
| HC338358a/HC338358a.sas | Job 58a: same BMIPCT_C2 logistic model as job 58 on the PRS-complete imputed sample; produces Table 3a. |
| HC338361/HC338361.sas | Job 61: same pooled model Table 2 structure as job 54 with response BMIZ instead of WAZ. |
| HC338361a/HC338361a.sas | Job 61a: BMIZ Table 2 pipeline parallel to job 61 for the PRS-complete imputed sample. |
| HC338362/HC338362.sas | Job 62: pooled linear model for WAZ with child adjusted by HAZ; Table 2.2. |
| HC338362a/HC338362a.sas | Job 62a: same WAZ + HAZ adjustment as job 62 on the PRS-complete imputed sample; Table 2.2a. |
| HC338363/HC338363.sas | Job 63: pooled linear model for birth weight-for-gestational-age z-score (birthwt_ga_z); produces Table 5. |
| HC338363a/HC338363a.sas | Job 63a: birthwt_ga_z linear model pipeline; produces Table 5a. |
| HC338364/HC338364.sas | Job 64: pooled ordinal model for child BMI category BMIPCT_C3 (normal/overweight/obese); Table 4 (main sample). |
| HC338364a/HC338365.sas | Job 65: BMIPCT_C3 ordinal OR table (proportional odds; Model 4 covariates). |
| HC338357/HC338357.sas | Job 57: inclusion/exclusion table for analytic sample construction. |
| HC338390/HC338390.sas | Job 90: centralized PROC FORMAT definitions for categorical displays and reporting conventions used downstream. |
| HC338391/ | Job 91: shared SAS macros used across jobs (labels for PROC REPORT-style tables, pooling multiply imputed results, partial R² helpers, anonymization utilities). |
| HC338398/ | Job 98: analytic file QC—cross-checks and comparisons vs Statistical Computing reference datasets. |
| HC338399/ | Job 99 miscellaneous scripts. |

---

**Generated on:** 2026-05-20 using `generate_md.R` by Alvaro Quijano-Angarita
