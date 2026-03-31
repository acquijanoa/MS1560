%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
%let job = HC338399;
%let subjob = HC33839905;
proc printto log="&homepath.\scripts\&job.\&subjob._&sysdate..log"
	print = "&homepath.\scripts\&job.\&subjob._&sysdate..lst" new;
run;

/*********************************************************
*                                                        *
*  SAS PROGRAM - JOB HC33839905 			  			 *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC33839905.sas
*
*  PROGRAMMER: Alvaro Quijano (AQ)
*
*  DESCRIPTION: Histograms of child BMIPCT and BMIZ for
*               the FLOR MS1560 analytic cohort only
*               (KEEP_MS1560=1; n=227), same source file
*               that feeds HC338353 / jobs 54 & 59.
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338399 (subjob 05)
*
*  PREVIOUS JOB:
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL:
*					30mar26: Create file.
*					30mar26: Add BMIZ; restrict to FLOR cohort
*							 (KEEP_MS1560) on HC338351_flor.
*
* ----------------------------------------------------------
*
*  INPUT: data.HC338351_flor_12nov25 (KEEP_MS1560=1)
*
*  OUTPUT: &homepath.\scripts\&job.\&subjob._bmipct_bmiz_hist_&sysdate..rtf
*
**********************************************************/
options orientation = landscape nodate formchar = "|----|+|---+=|-/\<>*" nonumber
	PS=59 LS=173;
ods escapechar '^';

libname data "&homepath.\data";

%put JOB=&job.;
%put SUBJOB=&subjob.;
%let prg = AQA;
* Same FLOR analytic file used as input to HC338353 (imputation for jobs 54 / 59);
%let flordb = data.HC338351_flor_12nov25;

data _flor_ms1560;
	set &flordb;
	where keep_ms1560 = 1;
	keep id bmipct bmiz;
run;

proc sql noprint;
	select count(distinct id) into :n_flor trimmed
	from _flor_ms1560;
quit;
%put NOTE: FLOR MS1560 analytic cohort (KEEP_MS1560=1) distinct children: &n_flor;

ods listing close;
ods graphics on / width=640px height=480px;

ods rtf file="&homepath.\scripts\&job.\&subjob._bmipct_bmiz_hist_&sysdate..rtf"
	style=statistical bodytitle;

* --- BMIPCT ---;
title j=center font='Times New Roman' height=11pt
	"Child BMI-for-age percentile (CDC), FLOR MS1560 analytic cohort";
title2 j=center font='Times New Roman' height=10pt
	"KEEP_MS1560=1 (complete child anthropometry); n = &n_flor children";
footnote j=left font='Times New Roman' height=9pt
	"Source: HC338351_flor_12nov25, same cohort imputed in HC338353 (jobs 54 / 59 use HC338353_imputed_data_12nov25).";
footnote2 j=left font='Times New Roman' height=9pt
	"Job &subjob (job &job) by &prg on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))";

proc sgplot data=_flor_ms1560;
	where bmipct > .z;
	histogram bmipct / binwidth=5 scale=percent;
	xaxis label="BMI-for-age percentile" labelattrs=(family='Times New Roman' size=10pt);
	yaxis label="Percent of children" labelattrs=(family='Times New Roman' size=10pt);
run;

ods rtf startpage=now;

* --- BMIZ ---;
title j=center font='Times New Roman' height=11pt
	"Child BMI-for-age z-score (CDC), FLOR MS1560 analytic cohort";
title2 j=center font='Times New Roman' height=10pt
	"KEEP_MS1560=1 (complete child anthropometry); n = &n_flor children";

proc sgplot data=_flor_ms1560;
	where bmiz > .z;
	histogram bmiz / binwidth=0.25 scale=percent;
	xaxis label="BMI-for-age z-score" labelattrs=(family='Times New Roman' size=10pt);
	yaxis label="Percent of children" labelattrs=(family='Times New Roman' size=10pt);
run;

ods rtf close;
ods graphics off;
ods listing;

proc printto;
run;
