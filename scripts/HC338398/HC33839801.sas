%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\code\HC338398\HC33839801_&sysdate..log" 
	print = "&homepath.\code\HC338398\HC33839801_&sysdate..lst" new; 
run;

/*********************************************************
*                                                        *
*  SAS PROGRAM - JOB HC33839801 			  			     *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC33839801.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: QC process for the analysis file cont#1
				
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
					05MAY25 - Creates the file

* ----------------------------------------------------------
*
*  INPUT: 
*                                        
*  OUTPUT: 
*
**********************************************************/
options orientation = landscape nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 
ods escapechar '^';

* Set libraries name; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';
libname hc3383 'J:\HCHS\SC\Review\HC3383'; /* hc338301_flor.sas7bdat hc338301_all.sas7bdat*/

* Set macro variables; 
%let job = HC338398;
%let subjob = HC33839801;
%let prg = AQA;
%let db_flor = data.hc338351_flor_06may25;
%let db_all = data.hc338351_all_06may25;
%let comp_flor = hc3383.hc338301_flor;
%let comp_all = hc3383.hc338301_all;


ods rtf file = "&homepath.\code\&job.\&subjob._compare_flor_&sysdate..rtf";
proc compare data = &db_flor compare = &comp_flor listvar; id id;
run;
ods rtf close;

ods rtf file = "&homepath.\code\&job.\&subjob._compare_all_&sysdate..rtf";
proc compare data = &db_all compare = &comp_all listvar; id id;
run;
ods rtf close;

proc printto; run;
