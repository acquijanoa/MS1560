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
	
* ----------------------------------------------------------
*
*  INPUT: 
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
%let data = data.HC338351_flor_19aug25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

ods listing gpath = "&homepath.\code\&job.\gplot";
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath\code\&job.\&job._mi_&sysdate..rtf" bodytitle style=manuscrt;


* Transform variables to plot;
data db;
	set &data;
	
	log_bmi = log(bmi);
	log_anta10a = log(anta10a);
	agg_ment_sq = (agg_ment **2  - 1) / 2;
	agg_phys_cub = (agg_phys**3 - 1 )/ 3;

	if ^missing(child_prs_bmi_a);
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

title 'Variable: Body Mass Index in log-scale (log_BMI)';
%histogram_density(var = log_bmi);

title 'Variable: Waist girth in original scale (anta10a)';
%histogram_density(var = anta10a);

title 'Variable: Waist girth in log scale (log_anta10a)';
%histogram_density(var = log_anta10a);

title 'Variable: height';
%histogram_density(var = height);
	
title 'Variable: agg_ment';
%histogram_density(var = agg_ment_sq);

title 'Variable: agg_phys';
%histogram_density(var = agg_phys_cub);

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
	minimum= . . . . . . . . . . . . . 0 . 0 . . 0 . . . .  . .
	maximum= . . . . . . . . . . . . . 100 . . . . . . . . . . .;
  ods exclude modelinfo fcsmodel misspattern;
   class centernum bkgrd1_c7nomiss lang_pref
			employedyn n_hc current_smoker income_c2 /* binary variables */
			alcohol_use yrsus_c3 education_c3 marital_status;
   transform log(bmi) log(anta10a) 
				boxcox(agg_ment / lambda = 2) boxcox(agg_phys / lambda = 3) power(povpct / lambda=0.5);
   fcs reg(waz bmi anta10a agg_ment agg_phys height hei2010 povpct cesd10 stai10 pct_mvpa birthwt_ga_z slpdur)
	   regpmm(parity_v1);
   fcs logistic(employedyn n_hc current_smoker income_c2 / link=logit likelihood=augment)
			logistic(alcohol_use yrsus_c3 education_c3 marital_status);
   var waz centernum bkgrd1_c7nomiss YRSV1BIRTH age lang_pref
		birthwt_ga_z slpdur bmi anta10a agg_ment agg_phys height hei2010 povpct cesd10 stai10 parity_v1 pct_mvpa child_prs_bmi_a
		employedyn n_hc current_smoker income_c2 /* binary variables */
		alcohol_use yrsus_c3 education_c3 marital_status /* nominal/ordinal variables*/
		;
run;

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

* Summarize the imputated variables;
title 'Imputed variables';
%summary_imputation(vars=waz bmi anta10a agg_ment agg_phys height hei2010 povpct cesd10 stai10 parity_v1 pct_mvpa child_prs_bmi_a birthwt_ga_z slpdur
				employedyn n_hc current_smoker income_c2
				alcohol_use yrsus_c3 education_c3 marital_status);

proc freq data = db;
	table accult_mesa * yrsus_c3 / nopercent nocum norow nocol;
run;

proc reg DATA = db plots=none;
	MODEL WAZ = accult_mesa centernum YRSV1BIRTH bkgrd1_c7nomiss age income_c2 lang_pref 
				parity_v1 povpct  marital_status employedyn education_c3 yrsus_c3 n_hc  
				bmi anta10a height agg_ment agg_phys cesd10 stai10
				current_smoker hei2010 alcohol_use pct_mvpa birthwt_ga_z slpdur / vif collin;
quit;

proc means data = db;
	var waz centernum YRSV1BIRTH bkgrd1_c7nomiss age income_c3 lang_pref child_prs_bmi_a
				parity_v1 povpct accult_mesa marital_status employedyn education_c3 yrsus_c3 n_hc 
				bmi anta10a height agg_ment agg_phys cesd10 stai10
				current_smoker hei2010 alcohol_use pct_mvpa birthwt_ga_z slpdur;
run;
ods startpage = off;
proc means data = data.&job._imputed_data_&sysdate.;
	var waz centernum YRSV1BIRTH bkgrd1_c7nomiss age income_c3 lang_pref birthwt_ga_z slpdur
				parity_v1 povpct accult_mesa marital_status employedyn education_c3 yrsus_c3 n_hc  
				bmi anta10a height agg_ment agg_phys cesd10 stai10
				current_smoker hei2010 alcohol_use pct_mvpa child_prs_bmi_a;
run;

ods rtf close;

proc printto; run;
