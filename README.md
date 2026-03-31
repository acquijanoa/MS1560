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
| HC338359/HC338359.sas | Fits pooled linear GENMOD models for continuous child BMI-for-age percentile (BMIPCT) across imputations and generates Table 2 (Models 1–4) including model-specific partial R² summaries. |
| HC338359a/HC338359a.sas | Mirrors HC338359 in the PRS-complete imputed sample, producing the restricted-sample Table 2a and corresponding partial R² summaries. |
| HC338360/HC338360.sas | Fits fractional logit GEE models for continuous child BMI-for-age percentile (BMIPCT, 0–100) across imputations (dist=bin, link=logit, REPEATED SUBJECT=ID) to produce Table 2 and Average Marginal Effects (AMEs) for Model 4 on the BMI percentile scale. |
| HC338360a/HC338360a.sas | Mirrors HC338360 on the PRS-complete imputed sample, fitting the same fractional logit GEE models and generating Table 2a with AMEs for Model 4 in the restricted cohort. |
| HC338390/HC338390.sas | Defines centralized PROC FORMAT mappings (categorical labels, p-value symbols, report formatting helpers) used by downstream scripts. |
| HC338391/HC3383_labels.sas | Defines the %labels macro that standardizes variable labels, ordering, and display conventions for manuscript tables. |
| HC338391/HC3383_mi_lasso.sas | Provides the MI-lasso macro (Chen & Wang method) for variable selection in multiply imputed long-format data. |
| HC338391/HC3383_process_imputed.sas | Defines %process_imputed to pool parameter estimates across imputations via PROC MIANALYZE and attach reporting labels. |
| HC338391/HC3383_anonymize_db.sas | Defines %ANONYMIZE_DB to map SUBJECTID to study ID using transfer/encryption files and produce de-identified datasets. |
| HC338391/HC3383_partial_r2.sas | Defines %get_all_partial_r2 to compute variable-specific partial R2 across imputed GENMOD models using full vs reduced deviance. |
| HC338398/HC33839801.sas | Performs QC comparison (cont #1) between project-derived datasets and Statistical Computing comparison datasets using PROC COMPARE. |
| HC338398/HC33839802.sas | Performs QC comparison (cont #2) between project-derived datasets and updated Statistical Computing comparison datasets using PROC COMPARE. |
| HC338398/HC33839803.sas | Performs post-feedback QC comparison for cont #2 after incorporating review updates to derived datasets. |
| HC338398/HC33839804.sas | Runs QC reconstruction of Table 1 components (frequencies, summary stats, and p-values by FLOR status) against the all-participant analysis dataset. |
| HC338398/HC33839805.sas | Computes supplemental frequency counts used to document flow-chart and protocol eligibility/supporting manuscript denominator checks. |
| HC338399/HC33839901.sas | Computes HEI-2010 tertile cut points from the FLOR comparison dataset and exports the tertile summary report. |
| HC338399/HC33839902.sas | Calculates Pearson correlation between YRS_BTWN_V1V2 and YRSV1BIRTH in the FLOR comparison dataset. |
| HC338399/HC33839903.sas | Duplicate correlation script of HC33839902 (same PROC CORR analysis between YRS_BTWN_V1V2 and YRSV1BIRTH). |
| HC338399/HC33839904.sas | Runs an additional pooled Model 4 GENMOD analysis for WAZ including child sex and sex-by-alcohol interaction, then pools estimates with %process_imputed. |

---

**Generated on:** 2026-03-08 using `generate_md.R` by Alvaro Quijano-Angarita
