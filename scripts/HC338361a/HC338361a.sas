%let req=HC3383;
%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
%let job = &req.61a;
%let datefile = 29apr26;

proc printto log="&homepath.\scripts\&job.\&job._&sysdate..log" print=
	"&homepath.\scripts\&job.\&job._&sysdate..lst" new;
run;

/*********************************************************
 *                                                         *
 *  SAS PROGRAM - QC DATASET JOB HC3383 					         *
 *                                                        *
 **********************************************************
 *                                                        *
 *  PROGRAM NAME: HC338361a.sas
 *
 *  PROGRAMMER: Alvaro Quijano (AQ)
 *
 *  DESCRIPTION: Imputation model (replicate HC338354a job 54a);
 *               outcome is child BMI-for-age z-score (BMIZ)
 *               instead of weight-for-age z-score (WAZ).
 *
 * ---------------------------------------------------------
 *
 *  JOB NUMBER: HC338361a
 *
 *  PREVIOUS JOB: HC338361
 *
 *  LANGUAGE: SAS 9.4
 *
 *  VERSION CONTROL:
 *					13apr26: Create from HC338354a (job 54a);
 *							 response is BMIZ instead of WAZ.
 *					13apr26: Init macros &req, &job (&req.61a), &datefile;
 *							 impdb uses &datefile; printto/ODS use &job.
 *					29apr26: update imputed dataset to 29apr26 and replace
 *							 current_smoker with cigarette_use (models 2-4).
*					05may26: table_num macro variable added
 *
 * ----------------------------------------------------------
 *
 *  INPUT: DATA.HC338353a_imputed_data_<datefile> (see %let impdb)
 *
 *  OUTPUT:
 *
 **********************************************************/
options orientation=portrait nodate formchar="|----|+|---+=|-/\<>*" nonumber
	PS=59 LS=173;
ods escapechar '^';

* Set libraries name;
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

* Set macro variables;
%let prg=AQA;
%let impdb=data.HC338353a_imputed_data_&datefile.;
%let lf_margin=0.7in;
%let rg_margin=0.7in;
%let table_num=2a;

* Include sas scripts with formats and macros;
%include "&homepath.\scripts\HC338390\HC338390.sas";
%include "&homepath.\scripts\HC338391\HC3383_labels.sas";
%include "&homepath.\scripts\HC338391\HC3383_process_imputed.sas";
%include "&homepath.\scripts\HC338391\HC3383_partial_r2.sas";

* define macro variables;
%let pr2_class_vars=bkgrd1_c7nomiss marital_status employedyn education_c3 n_hc
	yrsus_c3 cigarette_use alcohol_use pag2008yn hei2010_c3 cesd10 stai10
	centernum;
%let pr2_cont_vars=age parity_v1 slpdur child_prs_bmi_a yrs_btwn_v1flor;
%let pr2_table_vars=&pr2_cont_vars centernum;

%macro normalize_effect(var=);
	%local _i _effect;
	%let _i=1;
	%do %while(%scan(&pr2_class_vars, &_i) ne );
		%let _effect=%upcase(%scan(&pr2_class_vars, &_i));
		if index(&var, cats("&_effect","_"))=1 then &var="&_effect";
		%let _i=%eval(&_i + 1);
	%end;
%mend;

* Fit the models using the imputed data;
title 'Model 1 - Sociodemographics';

proc genmod data=&impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN')
		marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED")
		education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN');
	model bmiz=centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 / d=normal ;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss
		bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn
		employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.;
	ods output ParameterEstimates=genmod_results_1;
run;

title 'Model 2: Model 1 + (diet, alcohol, smoke, pa, slpdur) ';

proc genmod data=&impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN')
		marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED")
		education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN') cigarette_use(REF="NEVER")
		alcohol_use(REF="NEVER") pag2008yn(ref="YES") hei2010_c3(ref="LOW");
	model bmiz=centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 cigarette_use hei2010_c3
		alcohol_use pag2008yn slpdur / dist=normal;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss
		bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn
		employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
		alcohol_use alcohol_use_fmt. cigarette_use cigarette_use_fmt. pag2008yn yn_fmt.
		hei2010_c3 hei2010_c3_fmt.;
	ods output ParameterEstimates=genmod_results_2;
run;

title 'Model 3: Model 2 + mental health';

proc genmod data=&impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN')
		marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED")
		education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN') cigarette_use(REF="NEVER")
		alcohol_use(REF="NEVER") pag2008yn(ref="YES") hei2010_c3(ref="LOW")
		cesd10(ref="NODEPRE") stai10(ref="NOANX");
	model bmiz=centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 cigarette_use hei2010_c3
		alcohol_use pag2008yn slpdur cesd10 stai10/ dist=normal;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss
		bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn
		employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
		alcohol_use alcohol_use_fmt. cigarette_use cigarette_use_fmt. pag2008yn yn_fmt.
		hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.;
	ods output ParameterEstimates=genmod_results_3;
run;

title 'Model 4: Model 3 + PRS';

proc genmod data=&impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN')
		marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED")
		education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN') cigarette_use(REF="NEVER")
		alcohol_use(REF="NEVER") pag2008yn(ref="YES") hei2010_c3(ref="LOW")
		cesd10(ref="NODEPRE") stai10(ref="NOANX");
	model bmiz=centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 cigarette_use hei2010_c3
		alcohol_use pag2008yn slpdur cesd10 stai10 child_prs_bmi_a/ dist=normal
		type3;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss
		bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn
		employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
		alcohol_use alcohol_use_fmt. cigarette_use cigarette_use_fmt. pag2008yn yn_fmt.
		hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.;
	ods output ParameterEstimates=genmod_results_4 ModelANOVA=type3;
	output out=_full_res resraw=e_full;
run;

* Process the imputed estimates;
%process_imputed(in_db=genmod_results_1, out_db=mianalize_1, model=1);
%process_imputed(in_db=genmod_results_2, out_db=mianalize_2, model=2);
%process_imputed(in_db=genmod_results_3, out_db=mianalize_3, model=3);
%process_imputed(in_db=genmod_results_4, out_db=mianalize_4, model=4);

* Merge datasets from different models;
data db_join;
	set mianalize_1 mianalize_2 mianalize_3 mianalize_4;
run;

* Run the macro using your imputed dataset;
%get_all_partial_r2(impdata=&impdb, class_vars=&pr2_class_vars,
	cont_vars=&pr2_cont_vars, outds=partial_r2_summary, outcome=bmiz);

data partial_r2_summary;
	set partial_r2_summary;
	length effect_name $32;
	effect_name=Dropped_Var;
	partial_r2_pct=Partial_R2_Pct;
	keep effect_name partial_r2_pct;
run;

data db_join;
	set db_join;
	length effect_name $32;
	effect_name=upcase(variable);
	%normalize_effect(var=effect_name);
run;

proc sql;
	create table db_join as select a.*, b.partial_r2_pct from db_join as a left
		join partial_r2_summary as b on a.effect_name=b.effect_name;
quit;

* Edit dataset to include reference values;
data db_join;
	set db_join;
	* Add ref levels;
	if std=99 then estimate=98;
	if model="Model 4" and (std=99 or findw(upcase("&pr2_cont_vars"),
		strip(effect_name), ' ')>0) then partial_r2_pct=partial_r2_pct;
	else partial_r2_pct=.;
	drop effect_name;
	format partial_r2_pct 8.1;
run;

* Obtain ids and save it in a macro variable ;
proc sql;
	select count(distinct(id)) as n into:n_ids from &impdb;
quit;

* Print final report;
ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file="&homepath\scripts\&job.\&job._Table&table_num._&sysdate..rtf" style=manuscrt
	bodytitle;
%let fs=11pt;
%let fs_body=11pt;
%let fs_titles=11pt;
%let lft_mgn=0.3in;
%let rgt_mgn=0.1in;

proc report data=db_join;
	title j=center height=&fs font='times roman' bold
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Table &table_num.. Maternal preconception socio-behavioral factors and child's BMI-for-age z-score, HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
	footnote1 J=left HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Abbreviations: CI, confidence interval; FLOR, Family Lifestyle Outcomes Research; PA, physical activity.";
	footnote2 J=left HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusted by field center, years between baseline and FLOR visit.";
	footnote3 J=left HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 2: Model 1 + health behavior predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote4 J=left HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 3: Model 2 + mental health predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote5 J=left HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 4: Model 3 + child's obesity genetic risk score.";
	footnote6 J=LEFT HEIGHT=10pt FONT='times roman'
		"{\line \line Job &job run by &prg using FLOR analytic file (HC338353a) on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))}";
	columns order label model,(estimate STD PV) partial_r2_pct;
	define order / order group noprint order=internal;
	define label / display group ' ' style(HEADER)=[FONTSIZE=&fs JUST=left]
		style=[FONTSIZE=&fs width=2.5in];
	define model / across ' ' style=[FONTSIZE=&fs];
	define estimate / analysis 'Beta' style=[fontsize=&fs vjust=bottom];
	define std / analysis '(SE)' style=[fontsize=&fs VJUST=bottom];
	define pv / analysis ' ' group style=[fontsize=&fs vjust=bottom just=left]
		style(header)=[cellpadding=0in cellheight=0in cellspacing=0in];
	define partial_r2_pct / mean "% Variance" style=[fontsize=&fs vjust=top
		just=center];
	FORMAT PV PV. STD paren. ESTIMATE refnum. partial_r2_pct pct_blank.;
	COMPUTE AFTER _PAGE_ / STYLE=[JUST=LEFT font_size=&fs];
	LINE "* p <=.10, ** p <=.05, *** p <=.01 ";
	ENDCOMP;
RUN;
ods rtf close;

proc printto;
run;
