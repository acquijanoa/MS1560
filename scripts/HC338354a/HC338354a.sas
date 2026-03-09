%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\scripts\HC338354a\HC338354a_&sysdate..log" 
	print = "&homepath.\scripts\HC338354a\HC338354a_&sysdate..lst" new; 
run;

/*********************************************************
*                                                         *
*  SAS PROGRAM - QC DATASET JOB HC3383 					         *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338354a.sas
*                                       
*  PROGRAMMER: �lvaro Quijano (AQ)
*
*  DESCRIPTION: Imputation model
				
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338354a 
*
*  PREVIOUS JOB: HC338354
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
*					04nov25: cc'ed HC338354
							 update job to 54a and table's title
							 update input dataset
					12nov25: Update input dataset to *_12nov25
					18nov25: update row labels and footnote
							 portrait orientation
							 LOW is the ref value for HEI2010_C3 now

* ----------------------------------------------------------
*
*  INPUT: HC338353a_imputed_data_ddmmyy;
*                                        
*  OUTPUT: 
*
**********************************************************/
options orientation=portrait nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 
ods escapechar '^';

* Set libraries name; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

* Set macro variables; 
%let job = HC338354a;
%let prg = AQA;
%let impdb = data.HC338353a_imputed_data_12nov25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

* Include sas scripts with formats and macros;
%include "&homepath.\scripts\HC338390\HC338390.sas";
%include "&homepath.\scripts\HC338391\HC3383_labels.sas";
%include "&homepath.\scripts\HC338391\HC3383_process_imputed.sas";
%include "&homepath.\scripts\HC338391\HC3383_partial_r2.sas";

%let pr2_class_vars = BKGRD1_C7NOMISS MARITAL_STATUS EMPLOYEDYN EDUCATION_C3 N_HC YRSUS_C3 CURRENT_SMOKER ALCOHOL_USE PAG2008YN HEI2010_C3 CESD10 STAI10;
%let pr2_cont_vars  = AGE PARITY_V1 SLPDUR CHILD_PRS_BMI_A;

%macro normalize_effect(var=);
	%local _i _effect;
	%let _i = 1;
	%do %while(%scan(&pr2_class_vars, &_i) ne );
		%let _effect = %upcase(%scan(&pr2_class_vars, &_i));
		if index(&var, cats("&_effect","_")) = 1 then &var = "&_effect";
		%let _i = %eval(&_i + 1);
	%end;
%mend;

* Fit the models using the imputed data;
title 'Model 1 - Sociodemographics';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN');
	model waz = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3 / d=normal ;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.;
	ods output ParameterEstimates=genmod_results_1;
run;

title 'Model 2: Model 1 + (diet, alcohol, smoke, pa, slpdur) ';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
			current_smoker(REF="NO") alcohol_use(REF="NEVER") 
			pag2008yn(ref="YES") hei2010_c3(ref="LOW"); 
	model waz = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3
			current_smoker hei2010_c3 alcohol_use pag2008yn slpdur / dist = normal;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			alcohol_use alcohol_use_fmt. current_smoker yn_fmt. 
			pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt.;
	ods output ParameterEstimates=genmod_results_2;
run;

title 'Model 3: Model 2 + mental health';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
			current_smoker(REF="NO") alcohol_use(REF="NEVER") 
			pag2008yn(ref="YES") hei2010_c3(ref="LOW")
			cesd10(ref="NODEPRE") stai10(ref="NOANX"); 
	model waz = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3
			current_smoker hei2010_c3 alcohol_use pag2008yn slpdur
			cesd10 stai10/ dist = normal;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			alcohol_use alcohol_use_fmt. current_smoker yn_fmt. 
			pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt.
			cesd10 cesd10_fmt. stai10 stai10_fmt.;
	ods output ParameterEstimates=genmod_results_3;
run;

title 'Model 4: Model 3 + PRS';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
			current_smoker(REF="NO") alcohol_use(REF="NEVER") pag2008yn(ref="YES") hei2010_c3(ref="LOW")
			cesd10(ref="NODEPRE") stai10(ref="NOANX");  
	model waz = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3
			current_smoker hei2010_c3 alcohol_use pag2008yn slpdur 
			cesd10 stai10
			child_prs_bmi_a/ dist = normal type3;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			alcohol_use alcohol_use_fmt. current_smoker yn_fmt. 
			pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt.
			cesd10 cesd10_fmt. stai10 stai10_fmt.;
	ods output ParameterEstimates=genmod_results_4
				ModelANOVA=type3;
	output out=_full_res resraw=e_full;
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

* Run the macro using your imputed dataset;
%get_all_partial_r2(impdata=&impdb, class_vars=&pr2_class_vars, cont_vars=&pr2_cont_vars, outds=partial_r2_summary);

data partial_r2_summary;
	set partial_r2_summary;
	length effect_name $32;
	effect_name = Dropped_Var;
	partial_r2_pct = Partial_R2_Pct;
	keep effect_name partial_r2_pct;
run;

data db_join;
	set db_join;
	length effect_name $32;
	effect_name = upcase(variable);
	%normalize_effect(var=effect_name);
run;

proc sql;
	create table db_join as
	select a.*, b.partial_r2_pct
	from db_join as a
	left join partial_r2_summary as b
		on a.effect_name = b.effect_name;
quit;

* Edit dataset to include reference values;
data db_join;
	set db_join;
	* Add ref levels;
	if std =99 then estimate = 98;
	if model = "Model 4" and std = 99 then partial_r2_pct = partial_r2_pct;
	else partial_r2_pct = .;
	drop effect_name;
	format partial_r2_pct 8.1;
run;

* Obtain ids and save it in a macro variable ;
proc sql;
	select count(distinct(id)) as n into:n_ids
	from &impdb;
quit;

* Print final report;
ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath\code\&job.\&job._Table2_&sysdate..rtf" style = manuscrt bodytitle;
%let fs = 11pt;
%let fs_body = 11pt;
%let fs_titles = 11pt;
%let lft_mgn = 0.3in;
%let rgt_mgn = 0.1in;
proc report data = db_join;
	title j=center height=&fs font='times roman' bold "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Table 2a. Maternal preconception socio-behavioral factors and child's weight-for-age z-score, HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
	footnote1 J=left HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Abbreviations: CI, confidence interval; FLOR, Family Lifestyle Outcomes Research; PA, physical activity.";
	footnote2 J=left HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusted by field center, years between baseline and FLOR visit.";
	footnote3 J=left HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 2: Model 1 + health behavior predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote4 J=left HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 3: Model 2 + mental health predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote5 J=left HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 4: Model 3 + child's obesity genetic risk score.";
	footnote6 J=LEFT HEIGHT=10pt FONT='times roman' "{\line \line Job &job run by &PRG using FLOR data on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))}";
	columns order label model,(estimate STD PV) partial_r2_pct;
	define order / order group noprint order = internal;
	define label / display group ' ' style(HEADER)=[FONTSIZE = &fs JUST = left] style = [FONTSIZE=&fs width = 2.5in];
	define model / across ' ' style = [FONTSIZE=&fs];
	define estimate / analysis 'Beta' style=[fontsize = &fs vjust = bottom];
	define std / analysis '(SE)' style=[fontsize = &fs VJUST = bottom]; 
	define pv / analysis ' ' group 
				style=[fontsize = &fs vjust=bottom just = left] 
				style(header)=[cellpadding = 0in cellheight=0in cellspacing=0in];
	define partial_r2_pct / display "Model 4 Partial R2 (%)" style=[fontsize=&fs just=center];
	FORMAT PV PV. STD paren. ESTIMATE refnum.;
	COMPUTE AFTER _PAGE_ / STYLE = [JUST = LEFT font_size = &fs];
		LINE "* p <=.10, ** p <=.05, *** p <=.01 ";
	ENDCOMP;
RUN;
ods rtf close;


proc printto; run;
