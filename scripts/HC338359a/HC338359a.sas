%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
%let job = HC338359a;
proc printto log="&homepath.\scripts\&job.\&job._&sysdate..log" 
	print = "&homepath.\scripts\&job.\&job._&sysdate..lst" new; 
run;

/*********************************************************
*                                                        *
*  SAS PROGRAM - QC DATASET JOB HC3383 					 *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338359a.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: Logistic model with Overweight/Obese as 
					the response; report OR and 95% CI
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338359a 
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
*					03dec25: create file 
*
* ----------------------------------------------------------
*
*  INPUT: 
*                                        
*  OUTPUT: 
*
**********************************************************/
options orientation = portrait nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 
ods escapechar '^';

* Set libraries name; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

* Set macro variables; 
%put JOB=&job.;
%let prg = AQA;
%let impdb = data.HC338353a_imputed_data_12nov25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

* Include sas scripts with formats and macros;
%include "&homepath.\scripts\HC338390\HC338390.sas";
%include "&homepath.\scripts\HC338391\HC3383_labels.sas";

%macro process_imputed_or(in_db=, out_db=, model=);

	data &in_db.;
		set &in_db.;
		length EffectName $50;
		if missing(Level1) then EffectName = Parameter;
		else EffectName = catx('_', Parameter, Level1);
	run;

	proc sort data=&in_db.; by EffectName; run;

	ods output ParameterEstimates=&out_db._p;
	proc mianalyze data=&in_db.;
		by EffectName;
		modeleffects Estimate;
		stderr StdErr;
	run;
	ods output close;

	data &out_db.;
		length model $10 or_txt $20 ci_txt $30;
		set &out_db._p(rename=(EffectName=variable));
		model = "Model &model.";

		* Handle CI variable names across MIANALYZE outputs;
		lcl = inputn(strip(vvaluex('LCLMean')), 'best32.');
		if missing(lcl) then lcl = inputn(strip(vvaluex('Lower')), 'best32.');
		ucl = inputn(strip(vvaluex('UCLMean')), 'best32.');
		if missing(ucl) then ucl = inputn(strip(vvaluex('Upper')), 'best32.');

		%labels;
		if variable not in ('Scale', 'Intercept');

		if std = 99 then do;
			or_txt = 'Ref.';
			ci_txt = ' ';
		end;
		else do;
			or_txt = strip(put(exp(estimate), 8.2));
			ci_txt = cats('(', strip(put(exp(lcl), 8.2)), ', ', strip(put(exp(ucl), 8.2)), ')');
		end;
	run;

%mend process_imputed_or;

* ;
data impdb;
	set &impdb.;

	if BMIPCT_C3 in (2,3) then BMIPCT_C2 = 1;
	else if BMIPCT_C3 = 1 then BMIPCT_C2 = 0;
	else BMIPCT_C2 = .;
	label BMIPCT_C2 = 'Respondent is Overweight or Obese';
run;

* Fit the models using the imputed data;
title 'Model 1 - Sociodemographics';
proc genmod data = impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN') bmipct_c2(ref='NORMAL');
	model bmipct_c2 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3 / d=binomial;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			bmipct_c2 bmipct_c2_fmt.
			;
	ods output ParameterEstimates=genmod_results_1;
run;

title 'Model 2: Model 1 + (diet, alcohol, smoke, pa, slpdur) ';
proc genmod data = impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
			current_smoker(REF="NO") alcohol_use(REF="NEVER") 
			pag2008yn(ref="YES") hei2010_c3(ref="LOW") bmipct_c2(ref='NORMAL'); 
	model bmipct_c2 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3
			current_smoker hei2010_c3 alcohol_use pag2008yn slpdur / dist = binomial;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			alcohol_use alcohol_use_fmt. current_smoker yn_fmt. 
			pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt.
			bmipct_c2 bmipct_c2_fmt.;
	ods output ParameterEstimates=genmod_results_2;
run;

title 'Model 3: Model 2 + mental health';
proc genmod data = impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
			current_smoker(REF="NO") alcohol_use(REF="NEVER") 
			pag2008yn(ref="YES") hei2010_c3(ref="LOW") 
			cesd10(ref="NODEPRE") stai10(ref="NOANX") bmipct_c2(ref='NORMAL'); 
	model bmipct_c2 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3
			current_smoker hei2010_c3 alcohol_use pag2008yn slpdur
			cesd10 stai10/ dist = binomial;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			alcohol_use alcohol_use_fmt. current_smoker yn_fmt. 
			pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt. 
			cesd10 cesd10_fmt. stai10 stai10_fmt.
			bmipct_c2 bmipct_c2_fmt.;
	ods output ParameterEstimates=genmod_results_3;
run;

title 'Model 4: Model 3 + PRS';
proc genmod data = impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
			current_smoker(REF="NO") alcohol_use(REF="NEVER") pag2008yn(ref="YES") hei2010_c3(ref="LOW") 
			cesd10(ref="NODEPRE") stai10(ref="NOANX") bmipct_c2(ref='NORMAL');  
	model bmipct_c2 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3
			current_smoker hei2010_c3 alcohol_use pag2008yn slpdur 
			cesd10 stai10
			child_prs_bmi_a/ dist = binomial;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			alcohol_use alcohol_use_fmt. current_smoker yn_fmt. 
			pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt.
			cesd10 cesd10_fmt. stai10 stai10_fmt.
			bmipct_c2 bmipct_c2_fmt.;
	ods output ParameterEstimates=genmod_results_4;
run;

* Process the imputed estimates;
%process_imputed_or(in_db = genmod_results_1, out_db = mianalize_1, model = 1);
%process_imputed_or(in_db = genmod_results_2, out_db = mianalize_2, model = 2);
%process_imputed_or(in_db = genmod_results_3, out_db = mianalize_3, model = 3);
%process_imputed_or(in_db = genmod_results_4, out_db = mianalize_4, model = 4);

* Merge datasets from different models;
data db_join;
	set mianalize_1 mianalize_2 mianalize_3 mianalize_4; 
run;

* Obtain ids and save it in a macro variable ;
proc sql;
	select count(distinct(id)) as n into:n_ids
	from &impdb;
quit;

* Print final report;
ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath\scripts\&job.\&job._Table3a_&sysdate..rtf" style = manuscrt bodytitle;
%let fs = 11pt;
%let fs_body = 11pt;
%let fs_titles = 11pt;
%let lft_mgn = 0.3in;
%let rgt_mgn = 0.1in;
proc report data = db_join;
	title j=center height=&fs font='times roman' bold "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Table 3a. Association among maternal preconception socio-behavioral factors and overweight or obesity, HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
	footnote1 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Abbreviations: CI, confidence interval; FLOR, Family Lifestyle Outcomes Research; PA, physical activity.";
	footnote2 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusted by field center, years between baseline and FLOR visit.";
	footnote3 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 2: Model 1 + health behavior predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote4 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 3: Model 2 + mental health predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote5 J=LEFT HEIGHT=&fs_titles FONT='times roman' "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 4: Model 3 + childs obesity genetic risk score.";
	footnote6 J=LEFT HEIGHT=10pt FONT='times roman' "{\line \line Job &job run by &PRG using FLOR data on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))}";
	columns order label model,(or_txt ci_txt pv);
	define order / order group noprint order = internal;
	define label / display group ' ' style(HEADER)=[FONTSIZE = &fs JUST = left] style = [FONTSIZE=&fs width = 2.5in];
	define model / across ' ' style = [FONTSIZE=&fs];
	define or_txt / display 'OR' style=[fontsize = &fs vjust = bottom];
	define ci_txt / display '95% CI' style=[fontsize = &fs VJUST = bottom];
	define pv / analysis ' ' group 
					style=[fontsize = &fs vjust=bottom just = left] 
					style(header)=[cellpadding = 0in cellheight=0in cellspacing=0in];
	FORMAT PV PV.;
	COMPUTE AFTER _PAGE_ / STYLE = [JUST = LEFT font_size = &fs];
		LINE "* p <=.10, ** p <=.05, *** p <=.01 ";
	ENDCOMP;
RUN;
ods rtf close;


proc printto; run;
