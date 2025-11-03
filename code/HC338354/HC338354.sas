%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\code\HC338354\HC338354_&sysdate..log" 
	print = "&homepath.\code\HC338354\HC338354_&sysdate..lst" new; 
run;

/*********************************************************
*                                                         *
*  SAS PROGRAM - QC DATASET JOB HC3383 					         *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338354.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: Imputation model
				
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338354 
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
					28apr25: Creates the file
					02jun25: Includes model 5 with child_prs_bmi_a data 
							 Update &imp_db file to *_02jun25
							 pct_pov excluded from models 4 and 5
					23jun25: input dataset updated (*.23jun25.sas7bdat)
								use yrsv1birth instead of yrs_btwn_v1flor
								add slpdur to the model
					20aug25: update input dataset
							 include full model (all the covariates) 
					02sep25: update response. Use 'birthwt_ga_z' instead of 'waz'
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
%let job = HC338354;
%let prg = AQA;
%let impdb = data.HC338353_imputed_data_20aug25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

* Include sas scripts with formats and macros;
%include "&homepath.\code\HC338390\HC338390.sas";
%include "&homepath.\code\HC338391\HC3383_labels.sas";
%include "&homepath.\code\HC338391\HC3383_process_imputed.sas";

* Fit the models using the imputed data;
title 'First domain - Sociodemographics';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") income_c2 lang_pref(ref="ENGLISH") bkgrd1_c7nomiss(ref='MEXICAN') 
			marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') 
			n_hc(ref="YES") yrsus_c3(ref='US_BORN');
	model birthwt_ga_z = centernum yrsv1birth bkgrd1_c7nomiss age income_c2 lang_pref parity_v1 
						povpct marital_status employedyn education_c3 yrsus_c3 n_hc / d=normal;
	format centernum centernum_fmt. income_c2 income_c2_fmt. lang_pref lang_pref_fmt. n_hc n_hc_fmt.
			bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn employedyn_fmt.
			yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.;
	ods output ParameterEstimates=genmod_results_1;
run;

title 'Second domain';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") ;
	model birthwt_ga_z = centernum yrsv1birth bmi anta10a height agg_ment agg_phys cesd10 stai10 / dist = normal;
	format centernum centernum_fmt.;
	ods output ParameterEstimates=genmod_results_2;
run;

title 'Third domain';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") current_smoker(REF="NO") alcohol_use(REF="NEVER");
	model birthwt_ga_z = centernum yrsv1birth current_smoker hei2010 alcohol_use pct_mvpa slpdur / dist = normal;
	format centernum centernum_fmt. alcohol_use alcohol_use_fmt. current_smoker yn_fmt.;
	ods output ParameterEstimates=genmod_results_3;
run;

title 'Full model';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") income_c2 lang_pref(ref="ENGLISH") bkgrd1_c7nomiss(ref='MEXICAN') 
			marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') 
			n_hc(ref="YES") yrsus_c3(ref='US_BORN') current_smoker(REF="NO") alcohol_use(REF="NEVER");
	model birthwt_ga_z = centernum yrsv1birth bkgrd1_c7nomiss age income_c2 lang_pref parity_v1 
						povpct marital_status employedyn education_c3 yrsus_c3 n_hc bmi anta10a height 
						agg_ment agg_phys cesd10 stai10 current_smoker hei2010 alcohol_use pct_mvpa slpdur  / d=normal;
	format centernum centernum_fmt. income_c2 income_c2_fmt. lang_pref lang_pref_fmt. n_hc n_hc_fmt.
			bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn employedyn_fmt.
			yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt. centernum centernum_fmt. alcohol_use alcohol_use_fmt. 
			bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. current_smoker yn_fmt.;
	ods output ParameterEstimates=genmod_results_4;
run;

title 'Significative factors model';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') ;
	model birthwt_ga_z = centernum yrsv1birth bkgrd1_c7nomiss marital_status height anta10a bmi slpdur / d=normal;
	format centernum centernum_fmt.	bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. ;
	ods output ParameterEstimates=genmod_results_5;
run;

title 'Full model + genetic risk';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') ;
	model birthwt_ga_z = centernum yrsv1birth bkgrd1_c7nomiss marital_status height anta10a bmi slpdur child_prs_bmi_a / d=normal;
	format centernum centernum_fmt.	bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. ;
	ods output ParameterEstimates=genmod_results_6;
run;

* Process the imputed estimates;
%process_imputed(in_db = genmod_results_1, out_db = mianalize_1, model = 1);
%process_imputed(in_db = genmod_results_2, out_db = mianalize_2, model = 2);
%process_imputed(in_db = genmod_results_3, out_db = mianalize_3, model = 3);
%process_imputed(in_db = genmod_results_4, out_db = mianalize_4, model = 4);
%process_imputed(in_db = genmod_results_5, out_db = mianalize_5, model = 5);
%process_imputed(in_db = genmod_results_6, out_db = mianalize_6, model = 6);

* Edit the 1st dataset to include the reference value;
data mianalize_1;
	set mianalize_1;
	
	if std =99 then estimate = 98;
run;

* merge the datasets from different models;
data db_join;
	set mianalize_1 mianalize_2 mianalize_3 mianalize_4 mianalize_5 mianalize_6;
run;

* ids ;
proc sql;
	select count(distinct(id)) as n into:n_ids
	from &impdb;
quit;

* print report;
ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath\code\&job.\&job._Table2_&sysdate..rtf" style = manuscrt bodytitle;
%let fs = 11pt;
%let fs_body = 11pt;
%let fs_titles = 11pt;
%let lft_mgn = 0.5in;
%let rgt_mgn = 0.5in;
proc report data = db_join;
	title j=center height=&fs font='times roman' bold "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Table 2. Maternal preconception socio-behavioral factors and child’s birth weight z-score, HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
	footnote1 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Abbreviations: CI, confidence interval; FLOR, Family Lifestyle Outcomes Research; MVPA, moderate-to-vigorous physical activity .";
	footnote2 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusting by field center, years between baseline and child's birth.";
	footnote3 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 2: Physical & Mental health, anthropometry predictors adjusting by field center, years between baseline and child's birth.";
	footnote4 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 3: Health behavior predictors adjusting by field center, years between baseline and FLOR.";
	footnote5 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 4: Include all the covariates.";
	footnote6 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 5: Only significant covariates from models 1, 2 and 3 adjusting by field center, years between baseline and child's birth.";
	footnote7 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 6: Model 5 + child’s obesity genetic risk score.";
	footnote8 J=LEFT HEIGHT=10pt FONT='times roman' "{\line \line Job &job run by &PRG using FLOR data on %sysfunc(today(), date9.) at %sysfunc(time(), timeampm.) }";
	columns order label model,(estimate STD PV);
	define order / order group noprint order = internal;
	define label / display group ' ' style(HEADER)=[FONTSIZE = &fs JUST = left] style = [FONTSIZE=&fs width = 2.1in];
	define model / across ' ' style = [FONTSIZE=&fs];
	define estimate / analysis 'Beta' style=[fontsize = &fs vjust = bottom];
	define std / analysis '(SE)' style=[fontsize = &fs VJUST = bottom]; 
	define pv / analysis ' ' group 
					style=[fontsize = &fs vjust=bottom just = left] 
					style(header)=[cellpadding = 0in cellheight=0in cellspacing=0in];
	FORMAT PV PV. STD paren. ESTIMATE refnum.;
	COMPUTE AFTER _PAGE_ / STYLE = [JUST = LEFT font_size = &fs];
		LINE ". <=.20, * p <=.10, ** p <=.05, *** p <=.01 ";
	ENDCOMP;
RUN;
ods rtf close;


proc printto; run;
