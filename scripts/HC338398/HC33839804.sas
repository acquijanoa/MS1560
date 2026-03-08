%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
%let job = HC338398;
%let subjob = HC33839804;
proc printto log="&homepath.\code\&job.\&subjob._&sysdate..log" 
	print = "&homepath.\code\&job.\&subjob._&sysdate..lst" new; 
run;

/*********************************************************
*                                                        *
*  SAS PROGRAM - JOB HC33839804			  			     *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC33839804.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: QC analysis of Table 1 from SC team
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338398
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
*					07aug25: Create the file
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
libname hc3383 'J:\HCHS\SC\Review\HC3383'; /* hc338301_flor.sas7bdat hc338301_all.sas7bdat*/

* Set macro variables; 
%let prg = AQA;
%let db_flor = data.hc338351_flor_28jul25;
%let db_all = data.hc338351_all_28jul25;
%let comp_flor = hc3383.hc338301_flor;
%let comp_all = hc3383.hc338301_all;

* Define formats ;
proc format;
	value flor_dyad_fmt
	0 = 'Non-FLOR dyads'
	1 = 'FLOR dyads';
	value bkgrd1_c7nomiss_fmt
	0 = 'Dominican'
	1 = 'Central American'
	2 = 'Cuban'
	3 = 'Mexican'
	4 = 'Puerto Rican'
	5 = 'South American'
	6 = 'Mixed/Other/Missing';
	value education_c3_fmt
	1 = 'Less than high school'
	2 = 'High school graduate'
	3 = 'Greater than high school';
	value income_c3_fmt
	1 = '<30.000'
	2 = '>=30.000'
	3 = 'Not reported';
	value marital_status_fmt
	1 = 'Single'
	2 = 'Married or with a partner'
	3 = 'Separated, divorced or widowed';
	value employedyn_fmt
	0 = 'No'
	1 = 'Yes';
	value lang_pref_fmt
	1 = 'Spanish'
	2 = 'English';
	value yrsus_c3_fmt
	1 = '<10 years'
	2 = '>= 10 years'
	3 = 'Born in US';
	value current_smoker_fmt
	0 = 'No'
	1 = 'Yes';
	value alcohol_use_fmt
	1 = 'Never' 
	2 = 'Former'
	3 = 'Current';
	value n_hc_fmt
	0 = "No"
	1 = "Yes";
	value demb1_fmt
	1 = "Boy"
	2 = "Girl";
run;

* Freqs;
%macro freqs(var=);
	ods startpage = on;
 * Print frequencies;
	ods rtf select none;
	proc freq data = &db_all.;
		table &var. * flor_dyad / norow nopercent chisq out=tab_freq;
		format flor_dyad flor_dyad_fmt. &var. &var._fmt.;
		ods output  CrossTabFreqs = tab_freqs0
						ChisQ = tab_p0;
	run;
	data tab_freqs;
		set tab_freqs0;
		drop table _table_ _type_ missing;

		rename colpercent=percent;
		if _type_ = '11';
		colpercent = colpercent / 100;
	run;
	ods rtf select all;
	proc report data = tab_freqs;
		title2 "&var.";
		column &var. flor_dyad,(Frequency Percent);
		define &var. / group 'Row var';
 		define flor_dyad / across '';
		define Frequency / analysis 'N' format=8.2;
		define Percent / analysis 'Percent' format=percent8.1; 
	run;
	ods startpage=no;
 * Print p-value;
	data tab_p;
		set tab_p0;
		keep variable prob;
		if statistic = 'Chi-Square';	
		variable = 'P value';
	run;
	proc print data = tab_p; 
		title2 "&var.";	
		title3 'P-value';
	run;
	ods startpage=now;
%mend freqs;

* T-test in flor dataset; 
%macro ttest_flor(var=);
	ods startpage = on;
	ods rtf select none;
	proc ttest data=&db_all. ;
		ods noproctitle;
		ods select statistics ttests;
		class flor_dyad;
		var &var.;
		format flor_dyad flor_dyad_fmt.;
		ods output statistics=tab_stats0
				ttests=tab_test0;
	quit;
	* Edit table with statistics;
	data tab_stats;
		set tab_stats0;
		keep rowvar class N Mean StdDev; 
		rename class=flor_dyad
				N=Frequency;
		rowvar = "&var.";
		if method = "";
	run;	
	ods rtf select all;
	proc report data=tab_stats;
		title2 "&var.";
		column rowvar flor_dyad,(Frequency Mean StdDev);
		define rowvar / group 'Row var';
 		define flor_dyad / across '';
		define mean / analysis 'Mean' format=8.1;
		define stdDev / analysis 'StdDev' format=8.1;
		define frequency / analysis 'N' format=8.0; 
	run;
	ods startpage=no;
	* Edit the test table output;
	data tab_test(rename=(var=Variable));
		set tab_test0;
		keep var probt;
		length var $ 10 ;
		var = 'P value';
		* subset method;
		if method = "Pooled";
	run;
	proc print data = tab_test;
		title2 "&var.";
		title3 'P-value';
	run;
	ods startpage=now;

%mend ttest_flor;


* Write RTF file;
ods rtf file = "&homepath.\code\&job.\&subjob._T1_qc_&sysdate..rtf" bodytitle;
title 'QC check of continuous variables';
* QC variables;
	%ttest_flor(var=age);
	%Freqs(var=bkgrd1_c7nomiss);
	%ttest_flor(var=parity_v1);
	%Freqs(var=education_c3);
	%Freqs(var=income_c3);
	%Freqs(var=marital_status);
	%Freqs(var=employedyn);
	%Freqs(var=yrsus_c3);
	%ttest_flor(var=povpct);
	%Freqs(var=n_hc);
	%Freqs(var=lang_pref);
	%ttest_flor(var=accult_mesa);
	%ttest_flor(var=agg_phys);
	%ttest_flor(var=agg_ment);
	%ttest_flor(var=cesd10);
	%ttest_flor(var=stai10);
	%ttest_flor(var=bmi);
	%ttest_flor(var=anta10a);
	%Freqs(var=current_smoker);
	%ttest_flor(var=hei2010);
	%ttest_flor(var=pct_mvpa);
	%freqs(var=alcohol_use);
	%ttest_flor(var=slpdur);
	%freqs(var=demb1);
	%ttest_flor(var=waz);
	%ttest_flor(var=birthwt_ga_z);
ods rtf close;

proc contents data = &db_all.; run;

proc printto; run;
