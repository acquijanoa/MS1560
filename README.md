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
| HC338302/HC338302.sas | Builds Table 1 with maternal preconception and child characteristics by FLOR dyad status, including group-wise summary statistics and p-values. |
| HC338351/HC338351.sas | Creates the core analysis datasets (FLOR-only and all eligible births), merges PRS and PA variables, and derives inclusion flags (KEEP_MS1560, PRS_COMPLETE, SLPDUR_LT8HRS). |
| HC338352/HC338352.sas | Generates missing-data pattern tables (PROC MI displaypattern) across manuscript domains for the FLOR analytic dataset. |
| HC338353/HC338353.sas | Runs multiple imputation (10 imputations) for the main FLOR analytic sample and derives post-imputation HEI2010_C3 and SLPDUR_LT8HRS. |
| HC338353a/HC338353a.sas | Runs multiple imputation for the PRS-complete subset (WHERE PRS_COMPLETE), with the same variable set as the main MI pipeline. |
| HC338353b/HC338353b.sas | Runs alternate multiple imputation using categorized HEI2010_C3 and SLPDUR_LT8HRS in the anthropometry-complete subset. |
| HC338353c/HC338353c.sas | Runs alternate multiple imputation (categorized HEI2010_C3/SLPDUR_LT8HRS) restricted to participants with complete PRS data. |
| HC338354/HC338354.sas | Fits pooled linear GENMOD models for WAZ across imputed datasets and produces Table 2 model estimates (Models 1-4; includes additional exploratory model run). |
| HC338354a/HC338354a.sas | Fits pooled linear GENMOD models for WAZ in the PRS-complete sample and generates the Table 2 counterpart for this restricted cohort. |
| HC338354a/HC338354a_20NOV25.sas | Frozen November 2025 snapshot of HC338354a used to reproduce the Table 2 restricted-sample results. |
| HC338354b/HC338354b.sas | Fits pooled linear GENMOD models for WAZ using alternate categorized behavior covariates and produces Table 2.1 (main sample). |
| HC338354c/HC338354c.sas | Fits pooled linear GENMOD models for WAZ using alternate categorized behavior covariates and produces Table 2.1 (restricted sample). |
| HC338355/HC338355.sas | Runs pooled univariate linear models across imputed datasets and summarizes top pairwise correlations among continuous variables for exploratory screening. |
| HC338356a/HC338356a.sas | Performs mediation analysis (PROC CAUSALMED + MIANALYZE) to generate Table 3a direct/indirect/total effects without child PRS in the covariate set. |
| HC338356b/HC338356b.sas | Performs mediation analysis (PROC CAUSALMED + MIANALYZE) to generate Table 3b direct/indirect/total effects including child PRS in the covariate set. |
| HC338357/HC338357.sas | Creates the inclusion/exclusion table and supporting missingness pattern output for the analytic sample construction workflow. |
| HC338358/HC338358.sas | Fits pooled binomial GENMOD models for overweight/obesity outcome (BMIPCT_C2) and generates Table 3 (main sample). |
| HC338358a/HC338358a.sas | Fits pooled binomial GENMOD models for overweight/obesity outcome (BMIPCT_C2) and generates Table 3a (restricted sample). |
| HC338359/HC338359.sas | Fits pooled linear GENMOD models for continuous BMI-for-age percentile (BMIPCT) across imputations to generate Table 2 (Models 1–4) and attach partial R² summaries via %get_all_partial_r2. |
| HC338359a/HC338359a.sas | Runs the same continuous BMIPCT linear GENMOD + partial R² pipeline as HC338359 in the PRS-complete imputed sample to produce Table 2a. |
| HC338360/HC338360.sas | Fits fractional logit GEE models for continuous BMI-for-age percentile (BMIPCT, 0–100) across imputed datasets (dist=bin, link=logit, REPEATED SUBJECT=ID) and produces Table 2 plus Average Marginal Effects (AMEs) for Model 4 on the BMI percentile scale. |
| HC338360a/HC338360a.sas | Runs the same fractional logit GEE and AME pipeline as HC338360 on the PRS-complete imputed sample to generate Table 2a for the restricted cohort. |
| HC338361/HC338361.sas | Job 61: Table 2 pooled linear models for BMIZ (main imputed sample; same structure as job 54). |
| HC338361a/HC338361a.sas | Job 61a: Table 2a pooled linear models for BMIZ (PRS-complete imputed sample). |
| HC338362/HC338362.sas | Job 62: Table 2 pooled linear models for WAZ with HAZ adjustment (main imputed sample). |
| HC338362a/HC338362a.sas | Job 62a: Table 2a pooled linear models for WAZ with HAZ adjustment (PRS-complete sample). |
| HC338363/HC338363.sas | Job 63: Table 2 pooled linear GENMOD models for birth weight-for-gestational-age z-score (birthwt_ga_z) in the main imputed sample (same structure as job 54). |
| HC338363a/HC338363a.sas | Job 63a: Table 2a pooled linear GENMOD models for birthwt_ga_z in the PRS-complete imputed sample (parallel to job 54a). |
| HC338364/HC338364.sas | Job 64: Table 2 pooled ordinal cumulative logit GENMOD models for child BMI category (BMIPCT_C3: normal/overweight/obese) in the main imputed sample. |
| HC338364a/HC338364a.sas | Job 64a: Table 2a pooled ordinal cumulative logit GENMOD models for child BMI category (BMIPCT_C3) in the PRS-complete imputed sample. |
| HC338390/HC338390.sas | Defines centralized PROC FORMAT mappings (categorical labels, p-value symbols, report formatting helpers) used by downstream scripts. |
| HC338391/HC3383_labels.sas | Defines the %labels macro that standardizes variable labels, ordering, and display conventions for manuscript tables. |
| HC338391/HC3383_mi_lasso.sas | Provides the MI-lasso macro (Chen & Wang method) for variable selection in multiply imputed long-format data. |
| HC338391/HC3383_process_imputed.sas | Defines %process_imputed to pool parameter estimates across imputations via PROC MIANALYZE and attach reporting labels. |
| HC338391/HC3383_anonymize_db.sas | Defines %ANONYMIZE_DB to map SUBJECTID to study ID using transfer/encryption files and produce de-identified datasets. |
| HC338391/HC3383_partial_r2.sas | Defines %get_all_partial_r2 to compute variable-specific partial R2 across imputed GENMOD models using full vs reduced deviance. |
| HC338398/ | Performs QC comparison between project-derived datasets and Statistical Computing datasets. |
| HC338399/ | Miscellaneous folder |

---

**Generated on:** 2026-04-30 using `generate_md.R` by Alvaro Quijano-Angarita
