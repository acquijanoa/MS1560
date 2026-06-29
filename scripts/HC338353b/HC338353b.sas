%let req=HC3383;
%let job = &req.53b;
%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\Manuscripts\MS1560;
%let datefile = 20may26;
proc printto log="&homepath.\scripts\&job.\&job._&sysdate..log" 
	print = "&homepath.\scripts\&job.\&job._&sysdate..lst" new; 
run;
/*********************************************************
*                                                         *
*  SAS PROGRAM - MI JOB HC3383     *
*                                                         *
**********************************************************
*                                                         *
*  PROGRAM NAME: HC338353b.sas
*                                       
*  PROGRAMMER: Alvaro Quijano (AQA)
*
*  TITLE:        Multiple imputation
*
*  DESCRIPTION:  PROC MI (10 imputations) for FLOR MS1560 cohort
*                (keep_ms1560) on full-granularity covariates (same model as
*                HC338353). Post-process collapsed Hispanic/Latino background
*                (3 categories), marital status (2 categories), smoking (never
*                vs current or former), HEI2010_C3, and SLPDUR_LT8HRS.
*
*  MANUSCRIPT:   MS1560
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338353b
*
*  PREVIOUS JOB: HC338351
*
*  LANGUAGE: SAS 9.4
*
*  DATE:         29jun26
*
*  VERSION CONTROL: 
*		29jun26: Create from HC338353; output imputed dataset dated with
*			 run date (&sysdate.) for traceability.
*			 Impute full-granularity covariates; derive collapsed variables
*			 after MI (bkgrd1_c3nomiss, marital_status_c2, cigarette_use_c2).
* ----------------------------------------------------------
*
*  INPUT:  HC338351_flor_&datefile..sas7bdat
*                                        
*  OUTPUT: HC338353b_imputed_data_&sysdate..sas7bdat
*          HC338353b_mi_&sysdate..rtf
*
**********************************************************/
options orientation=landscape ps=59 ls=173 nodate nonumber nocenter
        formchar="|----|+|---+=|-/\<>*" mprint varinitchk=error
        validvarname=upcase;
ods escapechar='^';

* Set libraries; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

* Define macro variables; 
%let prg = AQA;
%let data = data.HC338351_flor_&datefile.;
%let impds = &job._imputed_data_&sysdate.;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

* Set footnote; 
footnote "&sysdate -- &job (&prg)";

ods listing gpath = "&homepath.\scripts\&job.\gplot";
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods listing close;
ods rtf file = "&homepath.\scripts\&job.\&job._mi_&sysdate..rtf" bodytitle style=manuscrt;

* Transform variables to produce plots;
data db;
	set &data;
run;

* Plot the continuous variables;
%macro histogram_density(var=);
	proc sgplot data = db;
		histogram &var.;
		density &var. / type = normal; 
	run;
%mend histogram_density;

title 'Variable: Weight-for-age (WAZ)';
%histogram_density(var = waz);

title 'Variable: hei2010';
%histogram_density(var = hei2010);

title 'Variable: pag2008yn';
proc sgplot data=db;
	vbar pag2008yn;
run;

title 'Variable: child_prs_bmi_a';
%histogram_density(var = child_prs_bmi_a);

title 'Variable: sleep duration';
%histogram_density(var=slpdur);

title 'Variable: birthwt_ga_z';
%histogram_density(var=birthwt_ga_z);

title 'Variable: bmiz';
%histogram_density(var=bmiz);

* Impute variables of interest;
proc mi data=db out=data.&impds. nimpute=10 seed=3383
	minimum= . . . . . . . 0 . . . . 0 . . . . . . . . 
	maximum= . . . . . . . . . . . . . . . . . . . . . ;
   ods exclude modelinfo fcsmodel misspattern;
   class centernum bkgrd1_c7nomiss employedyn n_hc
			cigarette_use alcohol_use yrsus_c3 education_c3 marital_status pag2008yn;
   fcs reg(waz cesd10 stai10 child_prs_bmi_a birthwt_ga_z hei2010 slpdur)
	   regpmm(parity_v1);
   fcs logistic(employedyn n_hc pag2008yn / link=logit likelihood=augment) 
	   logistic(cigarette_use alcohol_use yrsus_c3 education_c3 marital_status / likelihood=augment);	
	var waz centernum bkgrd1_c7nomiss yrs_btwn_v1flor age birthwt_ga_z slpdur
		hei2010 cesd10 stai10 parity_v1 pag2008yn child_prs_bmi_a
		employedyn n_hc cigarette_use
		alcohol_use yrsus_c3 education_c3 marital_status
		bmiz
		;
	where keep_ms1560;
run;

* Macro to summarize imputed dataset;
%macro summary_imputation(vars=);
	proc means data = data.&impds. nmiss;
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
%summary_imputation(vars=waz birthwt_ga_z slpdur hei2010 cesd10 stai10 parity_v1 pag2008yn child_prs_bmi_a
				employedyn n_hc cigarette_use alcohol_use yrsus_c3 education_c3 marital_status);

* Post-process: collapse covariates and categorize hei2010 and slpdur;
data data.&impds.;
	set data.&impds.;

	if not missing(bkgrd1_c7nomiss) then do;
		if bkgrd1_c7nomiss = 3 then bkgrd1_c3nomiss = 1;
		else if bkgrd1_c7nomiss in (0, 2, 4) then bkgrd1_c3nomiss = 2;
		else if bkgrd1_c7nomiss in (1, 5, 6) then bkgrd1_c3nomiss = 3;
	end;
	else bkgrd1_c3nomiss = .;

	if not missing(marital_status) then do;
		if marital_status in (1, 3) then marital_status_c2 = 1;
		else if marital_status = 2 then marital_status_c2 = 2;
	end;
	else marital_status_c2 = .;

	if not missing(cigarette_use) then do;
		if cigarette_use = 1 then cigarette_use_c2 = 1;
		else if cigarette_use in (2, 3) then cigarette_use_c2 = 2;
	end;
	else cigarette_use_c2 = .;

	label bkgrd1_c3nomiss = 'Hispanic/Latino background (3 categories)';
	label marital_status_c2 = 'Marital status (2 categories)';
	label cigarette_use_c2 = 'Cigarette use (never vs current or former)';

	if missing(SLPDUR) then SLPDUR_LT8HRS = .;
	else if SLPDUR < 8 then SLPDUR_LT8HRS = 1;
	else SLPDUR_LT8HRS = 0;
	label SLPDUR_LT8HRS = 'Sleep duration (<8 hours)';

	if HEI2010 <= 50.1 then HEI2010_C3 = 1;
	else if HEI2010 > 50.1 and HEI2010 <= 62.5 then HEI2010_C3 = 2;
	else if HEI2010 > 62.5 then HEI2010_C3 = 3;
	label HEI2010_C3 = '3-level Health Index Score 2010';
run;

title 'Contents in imputed dataset';
proc contents data = data.&impds.;
ods noproctitle;
run;

ods rtf close;
ods listing;

proc printto; run;
