%let req=HC3383;
%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
%let job = &req.64;
%let datefile = 29apr26;
proc printto log="&homepath.\scripts\&job.\&job._&sysdate..log"
	print = "&homepath.\scripts\&job.\&job._&sysdate..lst" new;
run;
/*********************************************************
*                                                        
*  SAS PROGRAM - JOB HC338364                            
*                                                        
**********************************************************
*                                                        
*  PROGRAM NAME: HC338364.sas   
* 
*  PROGRAMMER: Alvaro Quijano (AQ)                       
*                                                        
*  DESCRIPTION: Ordinal model for BMIPCT_C3              
*               (NORMAL/OVERWEIGHT/OBESE) using the      
*               same covariate logic as jobs 54/54a.     
*  
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338364 
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
*					30apr26: Creates the file
*
*					05may26: renamed to T4
* ----------------------------------------------------------
*
*  INPUT: HC338353_imputed_data_&datefile
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
%let prg = AQA;
%let impdb = data.HC338353_imputed_data_&datefile.;
%let lf_margin = 1.3in;
%let rg_margin = 0.7in;
%let table_num = 4;

* Include sas scripts with formats and macros;
%include "&homepath.\scripts\HC338390\HC338390.sas";
%include "&homepath.\scripts\HC338391\HC3383_labels.sas";

* Process imputed estimates (ordinal): keep intercept cut-points;
%macro process_imputed_ord(in_db=, out_db=, model=);
	data &in_db.;
	    set &in_db.;
	    length EffectName $50;
	    if missing(Level1) then EffectName = Parameter;
	    else EffectName = catx('_', Parameter, Level1);
	run;

	proc sort data = &in_db.;
		by EffectName;
	run;

	ods output ParameterEstimates = &out_db._p;
	proc mianalyze data=&in_db.;
	    by EffectName;
	    modeleffects Estimate;
	    stderr StdErr;
	run;
	ods output close;

	data &out_db.;
	 	set &out_db._p(keep=EffectName estimate StdErr Probt
						rename=(EffectName=variable));
		model = "Model &model.";
		%labels;
		if upcase(variable) = 'SCALE' then delete;
		if upcase(variable) = 'INTERCEPT' then label = 'Intercept 1';
		else if index(upcase(variable), 'INTERCEPT_') = 1 then do;
			if scan(variable, -1, '_') = '2' then label = 'Intercept 2';
			else if scan(variable, -1, '_') = '1' then label = 'Intercept 1';
			else label = 'Intercept';
		end;
	run;
%mend process_imputed_ord;

* Fit the models using the imputed data;
title 'Model 1 - Sociodemographics (Ordinal Cumulative Logit)';
proc genmod data = &impdb.;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE')
		employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN') BMIPCT_C3(ref='Normal');
	model BMIPCT_C3 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 / dist=multinomial link=cumlogit;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt.
		marital_status marital_status_fmt. employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt.
		education_c3 education_c3_fmt. BMIPCT_C3 bmipct_c3_fmt.;
	ods output ParameterEstimates = genmod_results_1;
	where keep_ms1560;
run;

title 'Model 2: Model 1 + (diet, alcohol, smoke, pa, slpdur)';
proc genmod data = &impdb.;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE')
		employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN') cigarette_use(ref="NEVER") alcohol_use(ref="NEVER")
		pag2008yn(ref="YES") hei2010_c3(ref="LOW") BMIPCT_C3(ref='Normal');
	model BMIPCT_C3 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 cigarette_use hei2010_c3
		alcohol_use pag2008yn slpdur / dist=multinomial link=cumlogit;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt.
		marital_status marital_status_fmt. employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt.
		education_c3 education_c3_fmt. alcohol_use alcohol_use_fmt. cigarette_use cigarette_use_fmt.
		pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt. BMIPCT_C3 bmipct_c3_fmt.;
	ods output ParameterEstimates = genmod_results_2;
	where keep_ms1560;
run;

title 'Model 3: Model 2 + mental health';
proc genmod data = &impdb.;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE')
		employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN') cigarette_use(ref="NEVER") alcohol_use(ref="NEVER")
		pag2008yn(ref="YES") hei2010_c3(ref="LOW") cesd10(ref="NODEPRE") stai10(ref="NOANX")
		BMIPCT_C3(ref='Normal');
	model BMIPCT_C3 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 cigarette_use hei2010_c3
		alcohol_use pag2008yn slpdur cesd10 stai10 / dist=multinomial link=cumlogit;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt.
		marital_status marital_status_fmt. employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt.
		education_c3 education_c3_fmt. alcohol_use alcohol_use_fmt. cigarette_use cigarette_use_fmt.
		pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.
		BMIPCT_C3 bmipct_c3_fmt.;
	ods output ParameterEstimates = genmod_results_3;
	where keep_ms1560;
run;

title 'Model 4: Model 3 + PRS';
proc genmod data = &impdb.;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE')
		employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN') cigarette_use(ref="NEVER") alcohol_use(ref="NEVER")
		pag2008yn(ref="YES") hei2010_c3(ref="LOW") cesd10(ref="NODEPRE") stai10(ref="NOANX")
		BMIPCT_C3(ref='Normal');
	model BMIPCT_C3 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1
		employedyn marital_status yrsus_c3 cigarette_use hei2010_c3 alcohol_use pag2008yn slpdur
		cesd10 stai10 child_prs_bmi_a / dist=multinomial link=cumlogit;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt.
		marital_status marital_status_fmt. employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt.
		education_c3 education_c3_fmt. alcohol_use alcohol_use_fmt. cigarette_use cigarette_use_fmt.
		pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.
		BMIPCT_C3 bmipct_c3_fmt.;
	ods output ParameterEstimates = genmod_results_4;
	where keep_ms1560;
run;

* Process pooled results;
%process_imputed_ord(in_db = genmod_results_1, out_db = mianalize_1, model = 1);
%process_imputed_ord(in_db = genmod_results_2, out_db = mianalize_2, model = 2);
%process_imputed_ord(in_db = genmod_results_3, out_db = mianalize_3, model = 3);
%process_imputed_ord(in_db = genmod_results_4, out_db = mianalize_4, model = 4);

data db_join;
	set mianalize_1 mianalize_2 mianalize_3 mianalize_4;
	if std = 99 then estimate = 98;
run;

proc sort data = db_join;
	by order label model;
run;

* Obtain ids and save it in a macro variable;
proc sql noprint;
	select count(distinct(id)) into :n_ids trimmed
	from &impdb.
	where keep_ms1560;
quit;

* Print final report;
ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath\scripts\&job.\&job._Table&table_num._&sysdate..rtf" style = manuscrt bodytitle;
%let fs = 11pt;
%let fs_titles = 11pt;
%let rgt_mgn = 0.1in;
proc report data = db_join;
	title j = center height = &fs font = 'times roman' bold
		"^S={leftmargin=&lf_margin rightmargin=&rgt_mgn}Table &table_num.. Maternal preconception socio-behavioral factors and child BMI category, HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
	footnote1 j = left height = &fs_titles font = 'times roman'
		"^S={leftmargin=&lf_margin rightmargin=&rgt_mgn}Outcome modeled as ordinal (Normal < Overweight < Obese) using cumulative logit. ";
	footnote2 j = left height = &fs_titles font = 'times roman'
		"^S={leftmargin=&lf_margin rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusted by field center, years between baseline and FLOR visit.";
	footnote3 j = left height = &fs_titles font = 'times roman'
		"^S={leftmargin=&lf_margin rightmargin=&rgt_mgn}Model 2: Model 1 + health behavior predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote4 j = left height = &fs_titles font = 'times roman'
		"^S={leftmargin=&lf_margin rightmargin=&rgt_mgn}Model 3: Model 2 + mental health predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote5 j = left height = &fs_titles font = 'times roman'
		"^S={leftmargin=&lf_margin rightmargin=&rgt_mgn}Model 4: Model 3 + child's obesity genetic risk score.";
	footnote6 j = left height = 10pt font = 'times roman'
		"{\line \line Job &job run by &prg using FLOR data on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))}";
	columns order label model,(estimate std pv);
	define order / order group noprint order = internal;
	define label / display group 'Predictor' style(header)=[fontsize=&fs just=left] style=[fontsize=&fs width=2.8in];
	define model / across ' ' style=[fontsize=&fs];
	define estimate / analysis 'Beta' style=[fontsize=&fs vjust=bottom just=center];
	define std / analysis '(SE)' style=[fontsize=&fs vjust=bottom just=center];
	define pv / analysis ' ' group style=[fontsize=&fs vjust=bottom just=left]
		style(header)=[cellpadding=0in cellheight=0in cellspacing=0in];
	format pv pv. std paren. estimate refnum.;
	compute after _page_ / style = [just=left font_size=&fs];
		line "* p <= .10, ** p <= .05, *** p <= .01";
	endcomp;
run;
ods rtf close;

proc printto; run;
