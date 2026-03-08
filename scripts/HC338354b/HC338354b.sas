%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\code\HC338354b\HC338354b_&sysdate..log" 
				print = "&homepath.\code\HC338354b\HC338354b_&sysdate..lst" new; 
run;

/*********************************************************
*                                                        *
*  SAS PROGRAM - QC DATASET JOB HC3383 			         *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338354b.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: Generates Table 2.1 
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338354b 
*
*  PREVIOUS JOB: HC338354
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
*					04nov25: cc'ed HC338354
							 add PAG2008YN, HEI2010_C3 and SLPDUR_LT8hrs
							 update input dataset to hc338353b

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
%let job = HC338354b;
%let prg = AQA;
%let impdb = data.HC338353b_imputed_data_04nov25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

* Include sas scripts with formats and macros;
%include "&homepath.\code\HC338390\HC338390.sas";
%include "&homepath.\code\HC338391\HC3383_labels.sas";
%include "&homepath.\code\HC338391\HC3383_process_imputed.sas";

* Fit the models using the imputed data;
title 'Model 1 - Sociodemographics';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN');
	model waz = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3 / d=normal;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.;
	ods output ParameterEstimates=genmod_results_1;
run;

title 'Model 2: Model 1 + (diet, alcohol, smoke, pa, slpdur) ';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
			current_smoker(REF="NO") alcohol_use(REF="NEVER") pag2008yn(ref="YES") slpdur_lt8hrs(ref="<8_hours") hei2010_c3(ref="HIGH");
	model waz = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3
			current_smoker hei2010_c3 alcohol_use pag2008yn slpdur_lt8hrs / dist = normal;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			alcohol_use alcohol_use_fmt. current_smoker yn_fmt. 
			slpdur_lt8hrs slpdur_lt8hrs_fmt. pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt.;
	ods output ParameterEstimates=genmod_results_2;
run;

title 'Model 3: Model 2 + mental health';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
			current_smoker(REF="NO") alcohol_use(REF="NEVER") pag2008yn(ref="YES") slpdur_lt8hrs(ref="<8_hours") hei2010_c3(ref="HIGH");
	model waz = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3
			current_smoker hei2010_c3 alcohol_use pag2008yn slpdur_lt8hrs
			cesd10 stai10/ dist = normal;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			alcohol_use alcohol_use_fmt. current_smoker yn_fmt. 
			slpdur_lt8hrs slpdur_lt8hrs_fmt. pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt.;
	ods output ParameterEstimates=genmod_results_3;
run;

title 'Model 4: Model 3 + PRS';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
			current_smoker(REF="NO") alcohol_use(REF="NEVER") pag2008yn(ref="YES") slpdur_lt8hrs(ref="<8_hours") hei2010_c3(ref="HIGH");
	model waz = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3
			current_smoker hei2010_c3 alcohol_use pag2008yn slpdur_lt8hrs
			cesd10 stai10
			child_prs_bmi_a/ dist = normal;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			alcohol_use alcohol_use_fmt. current_smoker yn_fmt.
			slpdur_lt8hrs slpdur_lt8hrs_fmt. pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt.;
	ods output ParameterEstimates=genmod_results_4;
run;

* Process the imputed estimates;
%process_imputed(in_db = genmod_results_1, out_db = mianalize_1, model = 1);
%process_imputed(in_db = genmod_results_2, out_db = mianalize_2, model = 2);
%process_imputed(in_db = genmod_results_3, out_db = mianalize_3, model = 3);
%process_imputed(in_db = genmod_results_4, out_db = mianalize_4, model = 4);

* Merge datasets from different models;
data db_join;
	set mianalize_1 mianalize_2 mianalize_3 mianalize_4; 
run;

* Edit dataset to include reference values;
data db_join;
	set db_join;
	* Add ref levels;
	if std =99 then estimate = 98;
run;

* Obtain ids and save it in a macro variable ;
proc sql;
	select count(distinct(id)) as n into:n_ids
	from &impdb;
quit;

* Print final report;
ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath\code\&job.\&job._Table2.1_&sysdate..rtf" style = manuscrt bodytitle;
%let fs = 11pt;
%let fs_body = 11pt;
%let fs_titles = 11pt;
%let lft_mgn = 0.5in;
%let rgt_mgn = 0.5in;
proc report data = db_join;
	title j=center height=&fs font='times roman' bold "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Table 2.1. Maternal preconception socio-behavioral factors and child’s weight-for-age z-score, HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
	footnote1 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Abbreviations: CI, confidence interval; FLOR, Family Lifestyle Outcomes Research; MVPA, moderate-to-vigorous physical activity .";
	*footnote2 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusting by field center, years between baseline and child's birth.";
	footnote2 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusted by field center, years between baseline and FLOR visit.";
	footnote3 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 2: Model 1 + health behavior predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote4 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 3: Model 2 + mental health predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote5 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 4: Model 3 + child’s obesity genetic risk score.";
	footnote6 J=LEFT HEIGHT=10pt FONT='times roman' "{\line \line Job &job run by &PRG using FLOR data on %sysfunc(today(), date9.) at %sysfunc(time(), timeampm.) }";
	columns order label model,(estimate STD PV);
	define order / order group noprint order = internal;
	define label / display group ' ' style(HEADER)=[FONTSIZE = &fs JUST = left] style = [FONTSIZE=&fs width = 2.5in];
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
