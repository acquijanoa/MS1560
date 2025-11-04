%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\code\HC338353a\HC338353a_&sysdate..log" 
	print = "&homepath.\code\HC338353a\HC338353a_&sysdate..lst" new; 
run;

/*********************************************************
*                                                         *
*  SAS PROGRAM - QC DATASET JOB HC3383 					         *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338353a.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: Imputation model (it does not impute child_prs_bmi_a)
				
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338353a
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL:  
					02jun25: Insert child_prs_bmi_a in the imputation model
							 Exclude observations with missing child_prs_bmi_a 
					23jun25: add birthwt_ga_z and slpdur to the model
					20aug25: Update input dataset (&data)
							 Use YRSV1BIRTH instead yrs_btwn_v1flor
					04nov25: update input dataset to *_04nov25
							 drop anthropometrics, physical and mental health scores (agg_ment agg_phys)
							 drop lang_pref, povpct and income_c2
							 use yrs_btwn_v1flor instead of yrsv1birth
	
* ----------------------------------------------------------
*
*  INPUT: 	HC338351_flor_03nov25 
*                                        
*  OUTPUT: 
*
**********************************************************/
options orientation = landscape nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 
ods escapechar '^';


* Set libraries name; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

* Set macro variables; 
%let job = HC338353a;
%let prg = AQA;
%let data = data.HC338351_flor_04nov25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

ods listing gpath = "&homepath.\code\&job.\gplot";
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath\code\&job.\&job._mi_&sysdate..rtf" bodytitle style=manuscrt;

* Transform variables to plot;
data db;
	set &data;
	
	* log_bmi = log(bmi);
	* log_anta10a = log(anta10a);
	* agg_ment_sq = (agg_ment **2  - 1) / 2;
	* gg_phys_cub = (agg_phys**3 - 1 )/ 3;
run;


* Boxcox transformation ;
/*
proc transreg data = db;
	model boxcox(agg_ment / convenient lambda = -10 to 10 by 0.05) = identity(log_bmi log_anta10a waz height employedyn n_hc current_smoker education_c3 income_c2); 
run;
proc transreg data = db;
	model boxcox(agg_phys / convenient lambda = -10 to 10 by 0.05) = identity(log_bmi log_anta10a waz height employedyn n_hc current_smoker education_c3 income_c2); 
run;
*/

* Plot the continuous variables;
%macro histogram_density(var=);
	proc sgplot data = db;
		histogram &var.;
		density &var. / type = normal; 
	run;
%mend histogram_density;

title 'Variable: Weight-for-age (WAZ)';
%histogram_density(var = waz);

* title 'Variable: Body Mass Index in log-scale (log_BMI)';
* %histogram_density(var = log_bmi);

* title 'Variable: Waist girth in original scale (anta10a)';
* %histogram_density(var = anta10a);

* title 'Variable: Waist girth in log scale (log_anta10a)';
* %histogram_density(var = log_anta10a);

* title 'Variable: height';
* %histogram_density(var = height);
	
* title 'Variable: agg_ment';
* %histogram_density(var = agg_ment_sq);

* title 'Variable: agg_phys';
* %histogram_density(var = agg_phys_cub);

title 'Variable: hei2010';
%histogram_density(var = hei2010);

title 'Variable: parity_v1';
%histogram_density(var = parity_v1);

title 'Variable: pct_mvpa';
%histogram_density(var = pct_mvpa);

title 'Variable: child_prs_bmi_a';
%histogram_density(var = child_prs_bmi_a);

* Impute variables of interest;
proc mi data=db out=data.&job._imputed_data_&sysdate. nimpute=10 seed=3383
	/* Var:  1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 					*/
	minimum= . . . . . . . 0 . . . . 0 0 . . . . . . . .
	maximum= . . . . . . . . . . . . . . . . . . . . . .;
   ods exclude modelinfo fcsmodel misspattern;
   class centernum bkgrd1_c7nomiss employedyn n_hc current_smoker /* binary variables */
			alcohol_use yrsus_c3 education_c3 marital_status;
   fcs reg(waz cesd10 stai10 child_prs_bmi_a birthwt_ga_z hei2010 pct_mvpa slpdur)
	   regpmm(parity_v1);
   fcs logistic(employedyn n_hc current_smoker / link=logit likelihood=augment) 
	   logistic(alcohol_use yrsus_c3 education_c3 marital_status);	
	var waz centernum bkgrd1_c7nomiss yrs_btwn_v1flor age birthwt_ga_z slpdur /* 1-7 */
		hei2010 cesd10 stai10 parity_v1 pct_mvpa child_prs_bmi_a /* 8-13 */
		employedyn n_hc current_smoker /* 14-16 */
		alcohol_use yrsus_c3 education_c3 marital_status /* nominal/ordinal variables */
		;
	where prs_bmi_complete;
run;

* Creates a macro to summarize imputation;
%macro summary_imputation(vars=);
	proc means data = data.&job.imputed_data_&sysdate. nmiss;
		by _imputation_;
		var &vars.;
		output out = a;
	run;
	proc transpose data = a out=b(drop=_label_ rename=(_name_= Variable));
		by _imputation_;
		id _stat_;
		var &vars.;
	run;
	proc sort data = b out=c; by Variable; run;
	proc print data = c; run;
%mend summary_imputation;

* Summarize the imputed variables;
title 'Imputed variables';
%summary_imputation(vars=waz birthwt_ga_z slpdur hei2010 cesd10 stai10 parity_v1 pct_mvpa child_prs_bmi_a
				employedyn n_hc current_smoker alcohol_use yrsus_c3 education_c3 marital_status);

* Print contents;
title 'Dimensions and variables in imputed dataset';
proc contents data = data.&job._imputed_data_&sysdate.;
	ods noproctitle;
run;

ods rtf close;

proc printto; run;
