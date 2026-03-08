%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
%let job=HC338399;
%let subjob=HC33839902;
proc printto log="&homepath.\code\&job.\&subjob._&sysdate..log" 
	print = "&homepath.\code\&job.\&subjob._&sysdate..lst" new; 
run;

/*********************************************************
*                                                        *
*  SAS PROGRAM - JOB HC33839902 			  			     *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC33839902.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: Compute Pearson Correlation between 
					yrsv1birth and yrs_btwn_v1v2
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338399
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
					19aug25 - Create the file

* ----------------------------------------------------------
*
*  INPUT: J:\HCHS\SC\Review\HC3383\hc338301_flor
*                                        
*  OUTPUT: &homepath.\code\&job.\&subjob._correlation_&sysdate..rtf
*
**********************************************************/
options orientation = landscape nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 
ods escapechar '^';

* ;

* Set libraries name; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';
libname hc3383 'J:\HCHS\SC\Review\HC3383'; /* hc338301_flor.sas7bdat hc338301_all.sas7bdat*/

* Set macro variables; 
%put JOB=&job.;
%put SUBJOB=&subjob.;
%let prg = AQ;
%let db_flor = hc3383.hc338301_flor;
%let db_all = hc3383.hc338301_flor;

* Add footnote;
footnote J=center height=10pt font='times roman' "&sysdate, &systime -- &subjob (job: &job) by &prg using HC338301_flor data";

* Number of ids;
proc sql noprint;
	select count(distinct(id)) into:n_ids
	from &db_flor.;
quit;

ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath.\code\&job.\&subjob._correlation_&sysdate..rtf" style=manuscrt;
Title "Pearson correlation between time between V1 and V2 and Years between visit 1 and birth, FLOR (n=%qtrim(&n_ids.))";
proc corr data = &db_flor. plots=scatter(nvar=all);
	var yrs_btwn_v1v2 yrsv1birth;
run;
ods rtf close;

proc printto; run;
