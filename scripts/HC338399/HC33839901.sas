%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\code\HC338399\HC33839901_&sysdate..log" 
	print = "&homepath.\code\HC338399\HC33839901_&sysdate..lst" new; 
run;

/*********************************************************
*                                                        *
*  SAS PROGRAM - JOB HC33839901 			  			     *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC33839901.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: QC process for the analysis file cont#1
				
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
					23jun25 - Create the file

* ----------------------------------------------------------
*
*  INPUT: 
*                                        
*  OUTPUT: 
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
%let job = HC338399;
%let subjob = HC33839901;
%let prg = aqa;
%let db_flor = data.hc338351_flor_06may25;
%let comp_flor = hc3383.hc338301_flor; /* Computing request analytic file */

* footnote;
footnote J=center height=10pt font='times roman' "&sysdate, &systime -- &subjob (job: &job) by &prg using  hc338301_flor data";

ods rtf file = "&homepath.\code\&job.\&subjob._hei2010_tertiles_&sysdate..rtf";

title 'Dataset used to retrieve tertiles values';
proc contents data = &comp_flor;
	ods select attributes;
run;

* compute tertiles using &comp_flor data;
proc univariate data = &comp_flor noprint;
 	var hei2010;
	output out=db_tertiles pctlpts=33.3 66.67 prtlpre=pctl_;
run; 

* Print computed tertiles;
proc print data = db_tertiles;
	title 'Retrieved tertiles values'; 
run;

ods rtf close;

proc printto; run;
