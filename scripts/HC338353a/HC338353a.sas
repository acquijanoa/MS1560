%let req=HC3383;
%let job = &req.53a;
%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\Manuscripts\MS1560;
%let datefile = 20may26;
proc printto log="&homepath.\scripts\&job.\&job._&sysdate..log" 
	print = "&homepath.\scripts\&job.\&job._&sysdate..lst" new; 
run;
/*********************************************************
*                                                         *
*  SAS PROGRAM - MI JOB HC3383 (PRS-complete subset)      *
*                                                         *
**********************************************************
*                                                         *
*  PROGRAM NAME: HC338353a.sas
*                                       
*  PROGRAMMER: Alvaro Quijano (AQA)
*
*  TITLE:        Multiple imputation (PRS-complete subset)
*
*  DESCRIPTION:  PROC MI (10 imputations) for FLOR MS1560
*                prs_complete=1; child_prs_bmi_a in model but
*                not imputed as missing (complete PRS subset).
*
*  MANUSCRIPT:   MS1560
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338353a
*
*  PREVIOUS JOB: HC338351
*
*  LANGUAGE: SAS 9.4
*
*  DATE:         02jun25
*
*  VERSION CONTROL:  
		02jun25: Insert child_prs_bmi_a in the imputation model
				 Exclude observations with missing child_prs_bmi_a 
		23jun25: add birthwt_ga_z and slpdur to the model
		20aug25: Update input dataset (&data)
				 Use YRSV1BIRTH instead yrs_btwn_v1flor
		04nov25: update input dataset to *_04nov25
				 drop anthropometrics, physical and mental health scores (agg_ment agg_phys)
				 drop lang_pref, povpct and income_c2
				 use yrs_btwn_v1flor instead of yrsv1birth
		12nov25: update input dataset to *_12nov25
				 update prs_bmi_complete to prs_complete
		29apr26: add cigarette_use in the imputation model (exclude current_smoker)
			     add bmiz in the imputation model
		20may26: update input dataset to *_20may26
		        
* ----------------------------------------------------------
*
*  INPUT:  HC338351_flor_&datefile..sas7bdat
*                                        
*  OUTPUT: HC338353a_imputed_data_&datefile..sas7bdat
*          HC338353a_mi_&sysdate..rtf
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
%let impds = &job._imputed_data_&datefile.;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

* Set footnote; 
footnote "&sysdate -- &job (&prg)";

ods listing gpath = "&homepath.\scripts\&job.\gplot";
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods listing close;
ods rtf file = "&homepath.\scripts\&job.\&job._mi_&sysdate..rtf" bodytitle style=manuscrt;

* Transform variables to plot;
data db;
	set &data.;
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

title 'Variable: parity_v1';
%histogram_density(var = parity_v1);

title 'Variable: pag2008yn';
proc sgplot data=db;
	vbar pag2008yn;
run;

title 'Variable: child_prs_bmi_a';
%histogram_density(var = child_prs_bmi_a);

title 'Variable: bmiz';
%histogram_density(var = bmiz);

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
	where prs_complete;
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

* Summarize the imputed variables;
title 'Imputed variables';
%summary_imputation(vars=waz birthwt_ga_z slpdur hei2010 cesd10 stai10 parity_v1 pag2008yn child_prs_bmi_a
				employedyn n_hc cigarette_use alcohol_use yrsus_c3 education_c3 marital_status);

* categorize hei2010 and slpdur;
data data.&impds.;
	set data.&impds.;

	if missing(SLPDUR) then SLPDUR_LT8HRS = .;
	else if SLPDUR < 8 then SLPDUR_LT8HRS = 1;
	else SLPDUR_LT8HRS = 0;
	label SLPDUR_LT8HRS = 'Sleep duration (<8 hours)';

	if HEI2010 <= 50.1 then HEI2010_C3 = 1;
	else if HEI2010 > 50.1 and HEI2010 <= 62.5 then HEI2010_C3 = 2;
	else if HEI2010 > 62.5 then HEI2010_C3 = 3;
	label HEI2010_C3 = '3-level Health Index Score 2010';
run;

title 'Dimensions and variables in imputed dataset';
proc contents data = data.&impds.;
ods noproctitle;
run;

ods rtf close;
ods listing;

proc printto; run;
