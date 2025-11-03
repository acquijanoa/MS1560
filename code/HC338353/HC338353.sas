%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\code\HC338353\HC338353_&sysdate..log" 
	print = "&homepath.\code\HC338353\HC338353_&sysdate..lst" new; 
run;

/*********************************************************
*                                                         *
*  SAS PROGRAM - QC DATASET JOB HC3383 					         *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338353.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: Imputation model
				
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338353 
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
					28apr25: Creates the file
					13may25: Update input file
					02jun25: Insert child_prs_bmi_a in the imputation model
					23jun25: Add slpdur and birthwt_ga_z to the model
					19aug25: Update input dataset (&data)
					20aug25: Use YRSV1BIRTH instead yrs_btwn_v1flor
					03nov25: update input dataset to *_03nov25
	
* ----------------------------------------------------------
*
*  INPUT: 
*                                        
*  OUTPUT: 
*
**********************************************************/
options orientation = landscape nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 
ods escapechar '^';

* Set libraries; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

* Set macro variables; 
%let job = HC338353;
%let prg = AQA;
%let data = data.HC338351_flor_03nov25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

ods listing gpath = "&homepath.\code\&job.\gplot";
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath\code\&job.\&job._mi_&sysdate..rtf" bodytitle style=manuscrt;

* Transform variables to produce plots;
data db;
	set &data;
	
	log_bmi = log(bmi);
	log_anta10a = log(anta10a);
	agg_ment_sq = (agg_ment **2  - 1) / 2;
	agg_phys_cub = (agg_phys**3 - 1 )/ 3;
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

title 'Variable: agg_ment';
%histogram_density(var = agg_ment_sq);

title 'Variable: agg_phys';
%histogram_density(var = agg_phys_cub);

title 'Variable: hei2010_c3';
%histogram_density(var = hei2010_c3);

title 'Variable: parity_v1';
%histogram_density(var = parity_v1);

title 'Variable: pct_mvpa';
%histogram_density(var = mvpa_lt1p5);

title 'Variable: child_prs_bmi_a';
%histogram_density(var = child_prs_bmi_a);

title 'Variable: sleep duration';
%histogram_density(var=slpdur_lt8hrs);

title 'Variable: birthwt_ga_z';
%histogram_density(var=birthwt_ga_z);

* Impute variables of interest;
proc mi data=db out=data.&job._imputed_data_&sysdate. nimpute=10 seed=3383
	minimum= . . . . . . . . . . 0 . 0 . . 0 . . . .  . .
	maximum= . . . . . . . . . . 100 . . . . . . . . . . .;
  ods exclude modelinfo fcsmodel misspattern;
   class centernum bkgrd1_c7nomiss lang_pref employedyn n_hc current_smoker income_c2 /* binary variables */
			alcohol_use yrsus_c3 education_c3 marital_status hei2010_c3 slpdur_lt8hrs mvpa_lt1p5;
   transform boxcox(agg_ment / lambda = 2) boxcox(agg_phys / lambda = 3) power(povpct / lambda=0.5);
   fcs reg(waz agg_ment agg_phys  povpct cesd10 stai10 child_prs_bmi_a  birthwt_ga_z)
	   regpmm(parity_v1);
   fcs logistic(employedyn n_hc current_smoker income_c2 slpdur_lt8hrs mvpa_lt1p5 / link=logit likelihood=augment)
			logistic(alcohol_use yrsus_c3 education_c3 marital_status hei2010_c3);
   var waz centernum bkgrd1_c7nomiss YRSV1BIRTH age lang_pref
		birthwt_ga_z slpdur_lt8hrs agg_ment agg_phys hei2010_c3 povpct cesd10 stai10 parity_v1 mvpa_lt1p5 child_prs_bmi_a
		employedyn n_hc current_smoker income_c2 /* binary variables */
		alcohol_use yrsus_c3 education_c3 marital_status /* nominal/ordinal variables*/
		;
run;

%macro summary_imputation(vars=);
	proc means data = data.&job._imputed_data_&sysdate. nmiss;
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
%summary_imputation(vars=waz birthwt_ga_z slpdur_lt8hrs agg_ment agg_phys hei2010_c3 povpct cesd10 stai10 parity_v1 mvpa_lt1p5 child_prs_bmi_a
				employedyn n_hc current_smoker income_c2
				alcohol_use yrsus_c3 education_c3 marital_status);

ods rtf close;

proc printto; run;
