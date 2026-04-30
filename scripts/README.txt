Manuscript #1560
Programmer: Alvaro Quijano-Angarita

History:   
	12nov25: job 53 and 53a, imputation model includes slpdur, hei2010 (continuous) and pag2008yn (categorical)
	         hei2010_c3 was derived after imputation.
		    job54 and 54a, fit the model across imputed datasets using hei2010_c3, pag2008yn and slpdur 
	13apr26: job 61 and 61a, replicate pooled GENMOD Table 2 pipeline with response BMIZ (BMI-for-age z-score) instead of WAZ.
	         job 62 and 62a, replicate job 54/54a with child HAZ (height-for-age z-score) added as a covariate in all models.

Domains: 
1. Maternal sociodemographic, acculturation
2. Physical, mental health and anthropometry
3. Maternal health behaviors

Model description:

	job: 54 and 54a
	response: waz (updated on 02sep25, 'waz' used before) 
					(on 04nov25 updated back to waz)
	adjusted by: centernum, yrs_btwn_v1fplor (yrs_v1birth before 04nov25)
	covariates (updated on 04nov25): 
		1st domain: 
		Model 1: bkgrd1_c7nomiss age parity_v1 marital_status employedyn education_c3 yrsus_c3 n_hc
		Model 2: model 1 + current_smoker alcohol_use + 
				(hei2010 or hei2010_c3) + (pct_mvpa or pag2008yn) + (slpdur or slpdur_lt8hrs)
		Model 3: Model 2 + CESD10 + STAI10 
		Model 4: Model 3 + child_prs_bmi_a

JOB:
51: Create the dataset used for QC'ing the analytic file
	output: hc338351_flor_ddmmyy.sas7bdat  
		  hc338351_all_ddmmyy.sas7bdat

52: Missing data pattern by original defined domains (in the manuscript)
	input:  hc338351_flor_ddmmyy.sas7bdat 				
	output: hc338352_missing_pattern_ddmmyy.rtf

### Imputation model ####

53: Imputation model [227 x 10imp] 
	note: child anthropometry is not imputed
		04nov25: PCT_MVPA, HEI2010 and SLPDUR variables in the imputation model
		12nov25: PAG2008YN, HEI2010_C3 and SLPDUR in the imputation model

	input: hc338351_flor_ddmmyy.sas7bdat 
	output: hc338353_imputed_data_ddmmyy.sas7bdat 		

53a: Imputation model [n=201x10]
	note: child anthropometry and child_prs_bmi_a are not imputed
		04nov25: PCT_MVPA, HEI2010 and SLPDUR variables in the imputation model
		12nov25: PAG2008YN, HEI2010_C3 and SLPDUR in the imputation model
	input: hc338351_flor_ddmmyy.sas7bdat
	output: hc338353a_imputed_data_ddmmyy.sas7bdat

53b: Imputation model [n=227x10] [It's not updated on 12nov25] ### Archived within old_files
	note: child anthropometry is not imputed
		PAG2008YN, HEI2010_C3 and SLPDUR_LT8HRS in the imputation model
	input: hc338351_flor_ddmmyy.sas7bdat
	output: hc338353b_imputed_data_ddmmyy.sas7bdat 		 

53c: Imputation model [n=201x10] [It's not updated on 12nov25] ### Archived within old_files
	note: child anthropometry and child_prs_bmi_a are not imputed
		PAG2008YN, HEI2010_C3 and SLPDUR_LT8HRS in the imputation model
	input: hc338351_flor_ddmmyy.sas7bdat
	output: hc338353c_imputed_data_ddmmyy.sas7bdat

### Regression and Mediation Analysis ###

54: Regression model [n=227]
	input: hc338353_imputed_data_ddmmyy.sas7bdat
	output: hc338354_Table2_ddmmyy.rtf	 

54a: Regression model [n=201] 
	input: hc338353a_imputed_data_ddmmyy.sas7bdat
	output: hc338354a_Table2_ddmmyy.rtf

54b: Regression model [n=227] ## Archived within old_files
	note: PAG2008YN, HEI2010_C3 and SLPDUR_LT8HRS in the model
	input: hc338353b_imputed_data_ddmmyy.sas7bdat
	output: hc338354b_Table2.1_ddmmyy.rtf

54c: Regression model [n=201] ### Archived within old_files
	note: PAG2008YN, HEI2010_C3 and SLPDUR_LT8HRS in the model
	input: hc338353c_imputed_data_ddmmyy.sas7bdat
	output: hc338354c_Table2.1_ddmmyy.rtf

55:  Table for individual associations (descriptive). 

56a: Mediation Analysis (excluding PRS from the model) n=291
	input:  hc338353_imputed_data_19aug25.sas7bdat
	output: hc338356a_T3a_&sysdate..rtf
	Note: it excludes PRS data from mediation analysis, but uses 
			imputed dataset with 291 observations.
		   it is created to verify that total effects are the
			same as those in Table 2 (column 4).

56b: Mediation Analysis including PRS
	input:  hc338353_imputed_data_19aug25.sas7bdat
	output: hc338356b_T3b_&sysdate..rtf

58: Logistic model [n=227]
	input: hc338353_imputed_data_ddmmyy.sas7bdat
	output: hc338354_Table3_ddmmyy.rtf	
	response: BMIPCT_C2 (overweight/obese) 

58a: Logistic model [n=201] 
	input: hc338353a_imputed_data_ddmmyy.sas7bdat
	output: hc338354a_Table3a_ddmmyy.rtf
	response: BMIPCT_C2 (overweight/obese) 

59: Linear GENMOD models for continuous child BMI-for-age percentile (BMIPCT) across imputations in the main analytic sample; produces Table 2 with Models 1–4 and % variance explained.
	input: hc338353_imputed_data_ddmmyy.sas7bdat
	output: HC338359_Table2_ddmmyy.rtf

59a: Same linear GENMOD as job 59 but restricted to the PRS-complete imputed sample; produces Table 2a for the restricted cohort.
	input: hc338353a_imputed_data_ddmmyy.sas7bdat
	output: HC338359a_Table2_ddmmyy.rtf

60: Fractional logit GEE model for continuous child BMI-for-age percentile (BMIPCT, 0–100) in the main imputed sample.
    Models BMIPCT/100 as a binomial proportion with trials=100 using PROC GENMOD (dist=bin, link=logit) with REPEATED SUBJECT=ID (GEE, robust variance).
    Produces Table 2 estimates (Models 1–4) and Average Marginal Effects (AMEs) for Model 4 on the expected BMI percentile scale.
    input: hc338353_imputed_data_ddmmyy.sas7bdat
    output: HC338360_Table2_ddmmyy.rtf (Table 2 fractional logit + AMEs)

60a: Same fractional logit GEE modeling pipeline as job 60, but restricted to the PRS-complete imputed sample.
     Uses hc338353a_imputed_data_ddmmyy.sas7bdat and generates the Table 2a counterpart (Models 1–4) and AMEs for Model 4 in the restricted cohort.
     input: hc338353a_imputed_data_ddmmyy.sas7bdat
     output: HC338360a_Table2_ddmmyy.rtf (Table 2a fractional logit + AMEs)

61: Regression model [n=227]
	note: Same pooled linear GENMOD structure as job 54; response is BMIZ instead of WAZ.
	input: hc338353_imputed_data_ddmmyy.sas7bdat
	output: HC338361_Table2_ddmmyy.rtf

61a: Regression model [n=201]
	note: Same as job 61 for the PRS-complete imputed sample (parallel to job 54a).
	input: hc338353a_imputed_data_ddmmyy.sas7bdat
	output: HC338361a_Table2_ddmmyy.rtf

62: Regression model [n=227]
	note: Same covariate set as job 54 with response WAZ; all models adjust for child HAZ.
	input: hc338353_imputed_data_ddmmyy.sas7bdat
	output: HC338362_Table2_ddmmyy.rtf

62a: Regression model [n=201]
	note: Same as job 62 for the PRS-complete imputed sample (parallel to job 54a) adjusting for hild HAZ.
	input: hc338353a_imputed_data_ddmmyy.sas7bdat
	output: HC338362a_Table2_ddmmyy.rtf

63: Regression model [n=227]
	note: Same pooled linear GENMOD structure as job 54; response is birth weight-for-gestational-age z-score (birthwt_ga_z) instead of WAZ.
	input: hc338353_imputed_data_ddmmyy.sas7bdat
	output: HC338363_Table2_ddmmyy.rtf

63a: Regression model [n=201]
	note: Same as job 63 for the PRS-complete imputed sample (parallel to job 54a).
	input: hc338353a_imputed_data_ddmmyy.sas7bdat
	output: HC338363a_Table2_ddmmyy.rtf
 
	
### Miscellaneous ### 	

02: Descriptive Table 1 (taken and adapted from SC - HC338302)

57: Inclusion/Exclusions table

90: Centralized variable formats

91: SAS Macros
	9101: Labels to include in proc report, used in job 54

98: Analytic file QC
	9801: Cont#1 Quality check
	9802: Cont#2 Quality check
	9803: Cont#2 comparison after QC comments  
	9804: Quality Check of Table 1 (by Statistical Computing Team)
	9805: Compute frequencies to support manuscript's flow chart 	

99: Misc scripts
	9901: hei2010 tertiles
