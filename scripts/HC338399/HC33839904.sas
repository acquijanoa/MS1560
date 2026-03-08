%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
%let job=HC338399;
%let subjob=HC33839904;
proc printto log="&homepath.\scripts\&job.\&subjob._&sysdate..log" 
	print = "&homepath.\scripts\&job.\&subjob._&sysdate..lst" new; 
run;

/*********************************************************
*                                                        *
*  SAS PROGRAM - JOB HC33839904 			  			     *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC33839904.sas
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

* Set libraries name; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';
libname hc3383 'J:\HCHS\SC\Review\HC3383'; /* hc338301_flor.sas7bdat hc338301_all.sas7bdat*/

* Set macro variables; 
%put JOB=&job.;
%put SUBJOB=&subjob.;
%let prg = AQ;
%let impdb = data.HC338353_imputed_data_12nov25;

* Include sas scripts with formats and macros;
%include "&homepath.\scripts\HC338390\HC338390.sas";
%include "&homepath.\scripts\HC338391\HC3383_process_imputed.sas";
%include "&homepath.\scripts\HC338391\HC3383_labels.sas";

proc contents data = &impdb.; run;

title 'Model 4: Model 3 + PRS';
proc genmod data = &impdb;
	by _imputation_;
	class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE') employedyn(ref="NOT_EMPLOYED") 
			education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
			current_smoker(REF="NO") alcohol_use(REF="NEVER") pag2008yn(ref="YES") hei2010_c3(ref="LOW") 
			cesd10(ref="NODEPRE") stai10(ref="NOANX");  
	model waz = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1 employedyn marital_status yrsus_c3
			current_smoker hei2010_c3 alcohol_use pag2008yn slpdur 
			cesd10 stai10
			child_prs_bmi_a
   			demb1 demb1 | alcohol_use  / dist = normal;
	format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. marital_status marital_status_fmt. 
			employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
			alcohol_use alcohol_use_fmt. current_smoker yn_fmt. 
			pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt.
			cesd10 cesd10_fmt. stai10 stai10_fmt.;
	ods output ParameterEstimates=genmod_results_4;
run;

%process_imputed(in_db = genmod_results_4, out_db = mianalize_4, model = 4);

proc print data = mianalize_4; run;
