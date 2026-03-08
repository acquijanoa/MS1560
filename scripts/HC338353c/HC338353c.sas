%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\code\HC338353c\HC338353c_&sysdate..log" 
	print = "&homepath.\code\HC338353c\HC338353c_&sysdate..lst" new; 
run;

/*********************************************************
*                                                         *
*  SAS PROGRAM - QC DATASET JOB HC3383 					         *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338353c.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: Imputation model (does not impute child_prs_bmi_a)
				
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338353c
*
*  PREVIOUS JOB: HC338353b
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL:  
					04nov25: cc'ed HC338353b
							 update flag variable
	
* ----------------------------------------------------------
*
*  INPUT: 	HC338351_flor_ddmmmyy
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
%let job = HC338353c;
%let prg = AQA;
%let data = data.HC338351_flor_04nov25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

ods listing gpath = "&homepath.\code\&job.\gplot";
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath\code\&job.\&job._mi_&sysdate..rtf" bodytitle style=manuscrt;

* Transform variables to plot;
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

title 'Variable: hei2010_c3';
%histogram_density(var = hei2010_c3);

title 'Variable: parity_v1';
%histogram_density(var = parity_v1);

title 'Variable: pag2008yn';
%histogram_density(var = pag2008yn);

title 'Variable: child_prs_bmi_a';
%histogram_density(var = child_prs_bmi_a);

* Impute variables of interest;
proc mi data=db out=data.&job._imputed_data_&sysdate. nimpute=10 seed=3383
	/* Var:  1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0  					*/
	minimum= . . . . . . . . 0 0 . . . . . . . . . .
	maximum= . . . . . . . . . . . . . . . . . . . . ;
  ods exclude modelinfo fcsmodel misspattern;
   class centernum bkgrd1_c7nomiss employedyn n_hc current_smoker /* binary variables */
			alcohol_use yrsus_c3 education_c3 marital_status hei2010_c3 slpdur_lt8hrs pag2008yn;
   fcs reg(waz cesd10 stai10 child_prs_bmi_a birthwt_ga_z)
	   regpmm(parity_v1);
   fcs logistic(employedyn n_hc current_smoker slpdur_lt8hrs pag2008yn / link=logit likelihood=augment) 
	   logistic(alcohol_use yrsus_c3 education_c3 marital_status hei2010_c3);	
	var waz centernum bkgrd1_c7nomiss yrs_btwn_v1flor age birthwt_ga_z slpdur_lt8hrs /* 1-7 */
		hei2010_c3 cesd10 stai10 parity_v1 pag2008yn child_prs_bmi_a /* 8-13 */
		employedyn n_hc current_smoker /* 14-16 */
		alcohol_use yrsus_c3 education_c3 marital_status /* nominal/ordinal variables */
		;
	where prs_bmi_complete;
run;
* Creates a macro to summarize imputation;
%macro summary_imputation(vars=);
	proc means data = data.&job.imputed_data_&sysdate. nmiss;
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
%summary_imputation(vars=waz hei2010_c3 cesd10 stai10 parity_v1 pag2008yn child_prs_bmi_a birthwt_ga_z slpdur_lt8hrs
				employedyn n_hc current_smoker alcohol_use yrsus_c3 education_c3 marital_status);

* Print contents;
title 'Dimensions and variables in imputed dataset';
proc contents data = data.&job._imputed_data_&sysdate.;
	ods noproctitle;
run;

ods rtf close;

proc printto; run;
