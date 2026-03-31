%let homepath=J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;

proc printto log="&homepath.\scripts\HC338360a\HC338360a_&sysdate..log" print=
	"&homepath.\scripts\HC338360a\HC338360a_&sysdate..lst" new;
run;

/*********************************************************
 *                                                         *
 *  SAS PROGRAM - QC DATASET JOB HC3383 					         *
 *                                                        *
 **********************************************************
 *                                                        *
 *  PROGRAM NAME: HC338360a.sas
 *
 *  PROGRAMMER: Alvaro Quijano (AQ)
 *
*  DESCRIPTION: Pooled GENMOD fractional logit for child
*               BMI-for-age percentile (BMIPCT, 0-100) in
*               the PRS-complete imputed sample; Table 2a.
*               events/trials: BMIPCT / TRIAL_WT (100),
*               dist=bin link=logit. SAS may NOTE
*               non-integer events.
 *
 * ---------------------------------------------------------
 *
 *  JOB NUMBER: HC338360a
 *
 *  PREVIOUS JOB: HC338360
 *
 *  LANGUAGE: SAS 9.4
 *
 *  VERSION CONTROL:
 *					30mar26: Create from HC338359a (job 59a);
 *							 fractional binomial probit for BMIPCT.
 *					30mar26: SCALE=DEVIANCE on MODEL (adjusted SEs).
 *
 * ----------------------------------------------------------
 *
 *  INPUT: HC338353a_imputed_data_ddmmyy;
 *
 *  OUTPUT:
 *
 **********************************************************/
options orientation = landscape nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173;
ods escapechar '^';

libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

%let job=HC338360a;
%let prg=AQA;
%let impdb=data.HC338353a_imputed_data_12nov25;
%let lf_margin=0.7in;
%let rg_margin=0.7in;

%include "&homepath.\scripts\HC338390\HC338390.sas";
%include "&homepath.\scripts\HC338391\HC3383_labels.sas";
%include "&homepath.\scripts\HC338391\HC3383_process_imputed.sas";

data impwork;
	set &impdb;
	trial_wt = 100;
	label trial_wt = "Denominator for fractional binomial (BMIPCT scale 0-100)";
run;

title 'Model 1 - Sociodemographics';
proc genmod data = impwork;
	by _imputation_;
	class id centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN')
		marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED")
		education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN');
	model bmipct / trial_wt =centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 / dist=bin link=logit;
	repeated subject=id / type=ind;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss
		bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn
		employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.;
	ods output GEEEmpPEst=genmod_results_1;
run;

title 'Model 2: Model 1 + (diet, alcohol, smoke, pa, slpdur) ';
proc genmod data=impwork;
	by _imputation_;
	class id centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN')
		marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED")
		education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN') current_smoker(REF="NO")
		alcohol_use(REF="NEVER") pag2008yn(ref="YES") hei2010_c3(ref="LOW");
	model bmipct / trial_wt =centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 current_smoker hei2010_c3
		alcohol_use pag2008yn slpdur / dist=bin link=logit;
	repeated subject=id / type=ind;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss
		bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn
		employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
		alcohol_use alcohol_use_fmt. current_smoker yn_fmt. pag2008yn yn_fmt.
		hei2010_c3 hei2010_c3_fmt.;
	ods output GEEEmpPEst=genmod_results_2;
run;

title 'Model 3: Model 2 + mental health';
proc genmod data=impwork;
	by _imputation_;
	class id centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN')
		marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED")
		education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN') current_smoker(REF="NO")
		alcohol_use(REF="NEVER") pag2008yn(ref="YES") hei2010_c3(ref="LOW")
		cesd10(ref="NODEPRE") stai10(ref="NOANX");
	model bmipct / trial_wt =centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 current_smoker hei2010_c3
		alcohol_use pag2008yn slpdur cesd10 stai10 / dist=bin link=logit;
	repeated subject=id / type=ind;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss
		bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn
		employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
		alcohol_use alcohol_use_fmt. current_smoker yn_fmt. pag2008yn yn_fmt.
		hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.;
	ods output GEEEmpPEst=genmod_results_3;
run;

title 'Model 4: Model 3 + PRS';
proc genmod data=impwork;
	by _imputation_;
	class id centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN')
		marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED")
		education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
		yrsus_c3(ref='US_BORN') current_smoker(REF="NO")
		alcohol_use(REF="NEVER") pag2008yn(ref="YES") hei2010_c3(ref="LOW")
		cesd10(ref="NODEPRE") stai10(ref="NOANX");
	model bmipct / trial_wt =centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
		parity_v1 employedyn marital_status yrsus_c3 current_smoker hei2010_c3
		alcohol_use pag2008yn slpdur cesd10 stai10 child_prs_bmi_a / dist=bin link=logit
		type3;
	repeated subject=id / type=ind;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss
		bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. employedyn
		employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
		alcohol_use alcohol_use_fmt. current_smoker yn_fmt. pag2008yn yn_fmt.
		hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.;
	output out=res xbeta=lin_pred;
	ods output GEEEmpPEst=genmod_results_4 ModelANOVA=type3;
run;

* Average Marginal Effects (Model 4, logit link): AME = E[p(1-p) * beta_i]; 
* where p = logistic(X*beta) is the mean of BMIPCT/100.;
data coef4;
	set genmod_results_4;
	length ParmName $32 EffectName $50;
	ParmName = coalescec(Parm, Parameter);
	if missing(Level1) then EffectName = ParmName;
	else EffectName = catx('_', ParmName, Level1);
run;

data res_with_p;
	set res;
	p = 1/(1+exp(-lin_pred));
run;

proc sql;
	create table ame_all as
	select c.EffectName,
		   mean( p * (1 - p) * c.Estimate ) as AME
	from res_with_p r
	inner join coef4 c
		on r._imputation_ = c._imputation_
	where upcase(c.ParmName) not in ('SCALE','INTERCEPT')
	group by c.EffectName;
quit;

data ame_all;
	set ame_all;
	rename EffectName = variable;
run;

%macro process_imputed2(in_db=, out_db=, model=);

	* Reshape the dataset to include effect names;
	data &in_db.;
	    set &in_db.;
	    length ParmName $32 EffectName $50;
	    ParmName = coalescec(Parm, Parameter);
	    if missing(Level1) then EffectName = ParmName;
	    else EffectName = catx('_', ParmName, Level1);
	run;

	* Sort the dataset by effect name;
	proc sort data = &in_db.; by Effectname; run;

	* Combine estimates in the imputated dataset using Rubin method in MiAnalize;
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
		if variable not in ('Scale','Intercept');
	run;

%mend process_imputed2;

* call the macro;
%process_imputed2(in_db = genmod_results_1, out_db = mianalize_1, model = 1);
%process_imputed2(in_db = genmod_results_2, out_db = mianalize_2, model = 2);
%process_imputed2(in_db = genmod_results_3, out_db = mianalize_3, model = 3);
%process_imputed2(in_db = genmod_results_4, out_db = mianalize_4, model = 4);

* merge datasets;
data db_join;
	set mianalize_1 mianalize_2 mianalize_3 mianalize_4;
run;
data db_join;
	set db_join;
	if std = 99 then estimate = 98;
run;

* Merge AMEs (for Model 4) into the dataset for reporting;
proc sort data=db_join; by variable; run;
proc sort data=ame_all; by variable; run;
proc sql;
	create table db_join as
	select *
	from db_join 
	left join ame_all 
		on db_join.variable = ame_all.variable 
	;
quit;
data db_join;
	set db_join;
	if model ne "Model 4" then AME = .;
	else if AME=0 then AME=.;
	else AME = 100*AME;
run;

proc sql;
	select count(distinct(id)) as n into :n_ids from impwork
		where bmipct > .z and trial_wt > 0;
quit;

ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file="&homepath\scripts\&job.\&job._Table2_&sysdate..rtf" style=manuscrt
	bodytitle;
%let fs=11pt;
%let fs_titles=11pt;
%let lft_mgn=0.3in;
%let rgt_mgn=0.1in;

proc report data=db_join;
	title j=center height=&fs font='times roman' bold
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Table 2a. Maternal preconception socio-behavioral factors and child's BMI-for-age percentile (fractional logit), HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
	footnote1 J=left HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Abbreviations: BMI-for-age percentile; FLOR, Family Lifestyle Outcomes Research.";
	footnote2 J=left HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Outcome: continuous BMI-for-age percentile (0-100) fit with PROC GENMOD binomial and logit link using MODEL BMI-for-age percentile / trial_wt (events/trials; trial_wt=100); non-integer events are allowed (SAS may print a note). Estimates are logit coefficients for E(BMI-for-age percentile/100).";
	footnote3 J=left HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusted by field center, years between baseline and FLOR visit.";
	footnote4 J=left HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 2: Model 1 + health behavior predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote5 J=left HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 3: Model 2 + mental health predictors adjusted by field center and years between baseline and FLOR visit.";
	footnote6 J=LEFT HEIGHT=&fs_titles FONT='times roman'
		"^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}^{super 1} Average Marginal Effect: represent the average change in the expected BMI-for-age percentile associated with a one-unit increase in each predictor.";
	footnote7 J=LEFT HEIGHT=10pt FONT='times roman'
		"{\line \line Job &job run by &PRG using FLOR data on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))}";
	columns order label model,(estimate STD PV) AME;
	define order / order group noprint order=internal;
	define label / display group ' ' style(HEADER)=[FONTSIZE=&fs JUST=left]
		style=[FONTSIZE=&fs width=2.5in];
	define model / across ' ' style=[FONTSIZE=&fs];
	define estimate / analysis 'Estimate' style=[fontsize=&fs vjust=bottom];
	define std / analysis '(SE)' style=[fontsize=&fs VJUST=bottom];
	define pv / analysis ' ' group style=[fontsize=&fs vjust=bottom just=left]
		style(header)=[cellpadding=0in cellheight=0in cellspacing=0in];
	define AME / analysis 'AME^{super 1}' style=[fontsize = &fs vjust = bottom];
	FORMAT PV PV. STD paren. ESTIMATE refnum. AME AME_fmt.;
	COMPUTE AFTER _PAGE_ / STYLE=[JUST=LEFT font_size=&fs];
	LINE "* p <=.10, ** p <=.05, *** p <=.01 ";
	ENDCOMP;
RUN;
ods rtf close;

proc printto;
run;
