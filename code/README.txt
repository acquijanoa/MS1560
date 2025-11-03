Manuscript #1560
Programmer: Alvaro Quijano-Angarita

Domains: 
1. Maternal sociodemographic, acculturation
2. Physical, mental health and anthropometry
3. Maternal health behaviors

Model description:

	job: 54 and 54a
	response: birthwt_ga_z (updated on 02sep25, 'waz' used before) 
	adjusted by: centernum, yrsv1birth
	covariates: 
		1st domain: bkgrd1_c7nomiss age income_c2 lang_pref parity_v1 povpct marital_status 
						employedyn education_c3 yrsus_c3 n_hc
		2nd domain: bmi anta10a height agg_ment agg_phys cesd10 stai10
		3rd domain: current_smoker hei2010 alcohol_use pct_mvpa slpdur
		Full model: bkgrd1_c7nomiss marital_status height anta10a bmi slpdur child_prs_bmi_a

JOB:

51: Create the dataset used for QC'ing the analytic file
	output: hc338351_flor_19aug25.sas7bdat  
		  hc338351_all_19aug25.sas7bdat

52: Missing data pattern by predefined domains (see list above)
	input:  hc338351_flor_19aug25.sas7bdat 				
	output: hc338352_missing_pattern_23jun25.rtf

### Imputation model ####

53: Imputation model (including child_prs_bmi_a) [n=291x10]
	input: hc338351_flor_19aug25.sas7bdat 
	output: hc338353_imputed_data_19aug25.sas7bdat 		

53a: Imputation model (child_prs_bmi_a not included) [n=201x10]
	input: hc338351_flor_20aug25.sas7bdat
	output: hc338353a_imputed_data_20aug25.sas7bdat 		 

### Regression and Mediation Analysis ###

54: Regression model by predefined domains [n=291]
	input: hc338353_imputed_data_20aug25.sas7bdat
	output: hc338354_Table2_20aug25.rtf

54a: Regression model by predefined domains [n=201] 
		(child_prs_bmi_a not imputed)
	input: hc338353a_imputed_data_20aug25.sas7bdat
	output: hc338354a_Table2_20aug25.rtf

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
	
### Miscellaneous ### 	

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
