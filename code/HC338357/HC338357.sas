%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560; 
%let job = HC338357;
proc printto log="&homepath.\code\&job.\&job._&sysdate..log" 
	print = "&homepath.\code\&job.\&job._&sysdate..lst" new; 
run;

/**********************************************************
*                                                         *
*  				SAS PROGRAM								  *
*                                                         *
***********************************************************
*                                                         *
*  Program name: HC338357.sas
*                                       
*  Programmer: Álvaro Quijano (AQ)
*
*  Description: 
*
* ---------------------------------------------------------
*
*  Job Number: hc338357
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
*					03nov25: create the file
							 excluded bmi, anta10a and height
*
* ----------------------------------------------------------
*
*  INPUT: &homepath.\data\hc338351_flor_19aug25
*                                        
*  OUTPUT: &homepath.\code\hc338357\hc338357_Inclusion/exclusion_&sysdate..rtf
*
**********************************************************/
options nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173 orientation=landscape; 
ods escapechar '^';

* Set libraries name; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

* Set macro variables;
%let prg = AQA;
%let db_in = data.hc338351_flor_19aug25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

* Create datasets with indicators for inclusion or exclusion;
data indicators_df;
	set &db_in;	
	keep inclusion_flor inclusion_ant inclusion_prs inclusion_covs;

	* flor participant;
	inclusion_flor = 1;

	* missing child anthropometry;
	if ^missing(child_weight) or ^missing(child_height) then inclusion_ant = 1; else inclusion_ant = 0;

	* If child_prs_bmi_a is missing;
	if ^missing(child_prs_bmi_a) then inclusion_prs = 1*inclusion_ant; else inclusion_prs = 0;

	* ;
	if nmiss(of yrsv1birth slpdur agg_ment agg_phys hei2010 povpct cesd10 stai10 parity_v1 pct_mvpa
		employedyn n_hc current_smoker income_c2 alcohol_use yrsus_c3 education_c3 marital_status) = 0 then inclusion_covs = 1*inclusion_prs; else inclusion_covs = 0; 
run;

* Calculate the frequency for each class;
proc means data = indicators_df sum noprint;
	var inclusion_flor inclusion_ant inclusion_prs inclusion_covs;
	output out = inclusion_tab sum= / autoname;
run;

* Transpose data;
proc transpose data = inclusion_tab out=inclusion_tab_t(rename=(col1=Inclusion));
	var inclusion_flor_sum inclusion_ant_sum inclusion_prs_sum inclusion_covs_sum;
run;

* create dataset with inclusion/exclusions/; 
data df_inclusions;
	set inclusion_tab_t;
	length label $ 50;
	drop type _name_ ;
		
	* Creates type variable;
	type = scan(_NAME_,2,'_');

	* Define label;
	if type = 'flor' then label = "Participated in FLOR study";
	if type = 'ant' then label = "Child anthropometry measured";
	if type = 'prs' then label = "Child PRS BMI (A) measured";
	if type = 'covs' then label = "Non-missing covariates";

	* creates variable for ordering;
	Order = _N_;
run;

* Sort data by order and creates the variables exclusions;
proc sort data = df_inclusions; by order; run;
data df_inclusions;
	set df_inclusions;

	* Exclusion;
	Exclusion = lag(Inclusion) - Inclusion;

	* Correct the first row values (missing);
	if Exclusion = . then Exclusion = 0;

	* Calculate percentages;
	p1 = 100*Inclusion/(Inclusion+Exclusion);
	p2 = 100-p1;
run;

* Create a dataset for the missingness pattern;
data db_MI;
	set &db_in;

	* subset data;
	if ^missing(child_weight) and ^missing(child_prs_bmi_a);
run;

* Write RTF file;
ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath.\code\&job.\&job._Inclusion_&sysdate..rtf" style = manuscrt bodytitle;
footnote1 j=left HEIGHT=10pt FONT='times roman' "{\line \line Job &job run by &PRG using FLOR data on %sysfunc(today(), date9.) at %sysfunc(time(), timeampm.) }";

	* Print RTF report;
	proc report data = df_inclusions; 
		title 'Inclusion and Exclusion Criteria for Manuscript MS#1560';
		ods noproctitle;
		column order Label Inclusion p1 Exclusion p2;
		define order / order=internal noprint;
		define label / 'Inclusion criteria'  style=[width=3in just=left];
		define p1 / analysis '%';
		define p2 / analysis '%';
		format p1 p2 8.2;
	run;

	* Print missingness pattern;
	title 'Missing data pattern';
	proc mi data = db_mi nimpute=0 displaypattern=nomeans;
		ods select MissPattern;
		var yrsv1birth slpdur  agg_ment agg_phys  hei2010 povpct cesd10 stai10 parity_v1 pct_mvpa
			employedyn n_hc current_smoker income_c2 alcohol_use yrsus_c3 education_c3 marital_status;
	run;

* close rtf file;
ods rtf close;


proc printto; run;
