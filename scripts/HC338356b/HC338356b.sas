%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560; 
%let job = HC338356b;
proc printto log="&homepath.\code\&job.\&job._&sysdate..log" 
	print = "&homepath.\code\&job.\&job._&sysdate..lst" new; 
run;

/**********************************************************
*                                                         *
*  SAS PROGRAM - QC DATASET JOB HC3383 					  *
*                                                         *
***********************************************************
*                                                         *
*  PROGRAM NAME: hc338356b.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: Mediation analysis using CAUSALMED procedure
*				Print table 3b.and include child_prs_bmi_a
* ---------------------------------------------------------
*
*  JOB NUMBER: hc338356b
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
					19aug25: create the file
					20aug25: rename output table
							 input dataset
* ----------------------------------------------------------
*
*  INPUT: &homepath.\data\hc338353_imputed_data_19aug25
*                                        
*  OUTPUT: &homepath.\code\hc338356\hc338356_Table3b_&sysdate..rtf
*
**********************************************************/
options nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 
ods escapechar '^';

* Set libraries name; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

* Set macro variables;
%let prg = AQA;
%put NOTE: JOB &job.;
%let db_in = data.hc338353_imputed_data_20aug25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

* Include sas scripts with formats and macros;
%include "&homepath.\code\HC338390\HC338390.sas";
%include "&homepath.\code\HC338391\HC3383_labels.sas";

* count ids;
proc sql noprint;
	select count(distinct id) into:n_ids
	from &db_in.
	where _imputation_ = 1;
quit;

* define macro variables;
%let adjust_var = centernum yrsv1birth bkgrd1_c7nomiss income_c2 lang_pref parity_v1 
						povpct marital_status employedyn education_c3 n_hc;

* creates the dummy;
data db_in;
	set &db_in.;

	* Years in the U.S.;
	yrsus_c3_l10 = (yrsus_c3=1);
	yrsus_c3_g10 = (yrsus_c3=2);

	* create dummy variables;
	alcohol_use_former = (alcohol_use=2);
	alcohol_use_current = (alcohol_use=3);
run;

%macro run_mediation(var=, covar=);

	* Mediation Analysis;
	proc causalmed data = db_in;
		by _imputation_;
		class centernum(ref="BRONX") income_c2 lang_pref(ref="ENGLISH") bkgrd1_c7nomiss(ref='MEXICAN') 
			marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') 
			n_hc(ref="YES") ; 
		model waz = birthwt_ga_z &var.;
		mediator birthwt_ga_z = &var.;
		covar &adjust_var. &covar.;
		ods output EffectSummary = db_&var._0;
		format centernum centernum_fmt. income_c2 income_c2_fmt. lang_pref lang_pref_fmt. n_hc n_hc_fmt.
			bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn employedyn_fmt.
			 education_c3 education_c3_fmt. centernum centernum_fmt. alcohol_use alcohol_use_fmt. ;
	run;

	* Sort dataset and exclude missing values;
	proc sort data = db_&var._0; 
		by Effect; 
		where Effect ^= 'Percentage Due to Interaction';
	run;

	* Combine values in the M imputed datasets;
	ods output ParameterEstimates = db_pooled; run;
	proc mianalyze data = db_&var._0; 
		by Effect;
		modeleffects Estimate;
		stderr StdErr;
	run;

	* edit dataset;
	data db_&var.;
		set db_pooled;
		keep Variable Eff Estimate LCLMean UCLMean;
		length Eff $ 8;	
		length variable $20;
		Variable = "&var.";

		* Create Eff variable;
		if Effect = 'Natural Direct Effect (NDE)' then Eff='Direct';
		if Effect = 'Natural Indirect Effect (NIE)' then Eff='Indirect';
		if Effect = 'Total Effect' then Eff = 'Total';

		* select rows in output dataset;
		if Eff in ('Direct','Indirect','Total');
run;
%mend run_mediation;

* run the macro;
%run_mediation(var=CHILD_PRS_BMI_A, covar=BMI ANTA10A height agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_g10);
%run_mediation(var=YRSUS_C3_L10, covar=BMI ANTA10A height agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=YRSUS_C3_G10, covar=BMI ANTA10A height agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 CHILD_PRS_BMI_A);
%run_mediation(var=BMI, covar=ANTA10A height agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=ANTA10A, covar=BMI height agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=HEIGHT, covar=ANTA10A BMI agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=AGG_MENT, covar=ANTA10A BMI HEIGHT agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=AGG_PHYS, covar=ANTA10A BMI HEIGHT agg_ment cesd10 stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=CESD10, covar=ANTA10A BMI HEIGHT agg_ment agg_phys stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=STAI10, covar=ANTA10A BMI HEIGHT agg_ment agg_phys cesd10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=CURRENT_SMOKER, covar=ANTA10A BMI HEIGHT agg_ment agg_phys cesd10 stai10 hei2010 alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=HEI2010, covar=ANTA10A BMI HEIGHT agg_ment agg_phys cesd10 stai10 current_smoker alcohol_use_former alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=ALCOHOL_USE_FORMER, covar=ANTA10A BMI HEIGHT agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_current pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=ALCOHOL_USE_CURRENT, covar=ANTA10A BMI HEIGHT agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_former pct_mvpa slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=PCT_MVPA, covar=ANTA10A BMI HEIGHT agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current slpdur yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);
%run_mediation(var=SLPDUR, covar=ANTA10A BMI HEIGHT agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use_former alcohol_use_current pct_mvpa yrsus_c3_l10 yrsus_c3_g10 CHILD_PRS_BMI_A);

* Merge datasets;
data db_join;
	set db_YRSUS_C3_L10 db_YRSUS_C3_G10 db_BMI db_ANTA10A db_HEIGHT db_AGG_MENT db_AGG_PHYS db_CESD10 db_STAI10 db_CURRENT_SMOKER 
			db_HEI2010 db_ALCOHOL_USE_FORMER db_ALCOHOL_USE_CURRENT db_PCT_MVPA db_SLPDUR db_CHILD_PRS_BMI_A;
	
	* create the column estimate (95% CI);
	length est_ci $40;
  	est_ci = compress(put(Estimate,8.2)) || " (" || compress(put(LCLMean,8.3) || ", ") || compress(put(UCLMean,8.3) || ")");
run;

* insert reference values;
proc sql;
 	insert into db_join
		values(.,.,.,'Direct','CURRENT_SMOKER_NO','Ref.')
		values(.,.,.,'Direct','ALCOHOL_USE_NEVER','Ref.')
		values(.,.,.,'Direct','YRSUS_C3_US_BORN','Ref.');
quit;

* Add labels into the dataset;
data db_join;
	set db_join;
	%labels;
run;

* Sorting the dataset;
proc sort data=db_join; by label order eff; run;

* Transpose data to print it;
proc transpose data=db_join out=db_wide prefix=est_ci_;
  by label order;
  id eff;
  var est_ci;
run;

* Print report;
ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath.\code\&job.\&job._T3b_&sysdate..rtf" style = manuscrt bodytitle;
%let fs = 11pt;
%let fs_body = 11pt;
%let fs_titles = 11pt;
%let lft_mgn = 0.5in;
%let rgt_mgn = 0.5in;
proc report data=db_wide nowd split='@';
    title j=center height=&fs font='times roman' bold "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Table 3b. Total, direct and infirect effects of maternal preconception socio-behavioral factors and child`s weight for age z-score (3-9), HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
	footnote1 j=left HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Abbreviations: CI, confidence interval; FLOR, Family Lifestyle Outcomes Research.";
	footnote2 j=left HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusting by field center, years between baseline and child's birth and socioeconomic factors.";
	footnote3 j=left HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Estimates were pooled acros 10 imputed datasets; confidence intervals reflect both within- and between-imputation variability";
	footnote4 j=left HEIGHT=10pt FONT='times roman' "{\line \line Job &job run by &PRG using FLOR data on %sysfunc(today(), date9.) at %sysfunc(time(), timeampm.) }";
  column order label ('Child`s weight score' est_ci_direct est_ci_indirect est_ci_total);
  define order / order order=internal noprint;
  define label  / "Maternal Preconception Factors" style=[width=3in];
  define est_ci_direct  / display "Direct @ ß (95% CI)" style=[just=center vjust=bottom];
  define est_ci_indirect  / display "Indirect @ ß (95% CI)" style=[just=center vjust=bottom];
  define est_ci_total  / display "Total @ ß (95% CI)" style=[just=center vjust=bottom];
run;
ods rtf close;

proc printto; run;
