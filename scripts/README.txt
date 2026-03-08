Manuscript #1560
Programmer: Alvaro Quijano-Angarita

History:   
	12nov25: job 53 and 53a, imputation model includes slpdur, hei2010 (continuous) and pag2008yn (categorical)
	         hei2010_c3 was derived after imputation.
		    job54 and 54a, fit the model across imputed datasets using hei2010_c3, pag2008yn and slpdur 

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

53b: Imputation model [n=227x10] [It's not updated on 12nov25]
	note: child anthropometry is not imputed
		PAG2008YN, HEI2010_C3 and SLPDUR_LT8HRS in the imputation model
	input: hc338351_flor_ddmmyy.sas7bdat
	output: hc338353b_imputed_data_ddmmyy.sas7bdat 		 

53c: Imputation model [n=201x10] [It's not updated on 12nov25]
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

54b: Regression model [n=227] 
	note: PAG2008YN, HEI2010_C3 and SLPDUR_LT8HRS in the model
	input: hc338353b_imputed_data_ddmmyy.sas7bdat
	output: hc338354b_Table2.1_ddmmyy.rtf

54c: Regression model [n=201] 
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
