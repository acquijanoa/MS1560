%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\code\HC338351\HC338351_&sysdate..log" 
	print = "&homepath.\code\HC338351\HC338351_&sysdate..lst" new; 
run;

/*********************************************************
*                                                         *
*  SAS PROGRAM - QC DATASET JOB HC3383 					         *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338351.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: 
				
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338351     
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
					21apr25 - (HC338351) Start file
					22apr25 - add the new derived variables cesd10 and accult_mesa
					05may25 - Include the #_all dataset
					08may25 - Updated to include the updates in cont#1(n_hc (v1 and v2) and alcohol_use variables)
					12may25 - Includes SC file (already QC'ed) as the starting point
					02jun25 - Include child_prs_bmi_a data
					06jun25 - Include birthweight from pce_derv
					23jun25 - Add cont#2 changes
					28jul25 - update the missing value in hei2010_c3
					19aug25 - Input SC datasets (hc3383.hc338301_all and *_flor) were updated and qc'ed in 18aug25
							- In this updated income_c2, pct_mvpa and hei2010_c3 are no longer derived
							- slpdur, slpdur_wkday, slpdur_wkend, baby1yn, daysv1birth, yrsv1birth and birthwt_ga_Z  
								are not imported anymore, since the SC file includes them
							- This file only imports prs data in this update

* ----------------------------------------------------------
*
*  INPUT: 
*                                        
*  OUTPUT: 
*
**********************************************************/
options orientation = landscape nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 

* Set libraries name; 
libname invv1 "J:\HCHS\SC\Sasdata\INV_Use\Consolidated";
libname invv2 "J:\HCHS\SC\Sasdata\Visit2\INV_Use\Consolidated";
libname flor "J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\INV_Use\Datasets";
libname confid 'J:\HCHS\SC\Confid\Sasdata\Visit2\Internal_Use';
libname output "&homepath.\data";
libname hc3383 "J:\HCHS\SC\Review\HC3383";
libname floriu "J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\Internal_Use";

* include macros;
%include "J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560\code\HC338391\HC3383_anonymize_db.sas";

* Set macro variables; 
%let pw = los_shch;
%let job = HC338351;

* Define the output dataset names;
%let output_dataset = output.HC338351_flor_&sysdate.;
%let output_dataset2 = output.HC338351_all_&sysdate.;

* Mask the subject's IDs in the IU dataset;
%anonymize_db(data = floriu.flor_grs_child_iu2(keep=subjectid child_prs_bmi_a), 
				out = flor_grs_child_iu2);

data &output_dataset2(label="All 1st live singleton births between V1 & V2 created on &sysdate.");
	merge hc3383.hc338301_all(in=in_a) 
			flor_grs_child_iu2;
	by id;
	
	* Include people in the the *_all file;
	if in_a;
run;

* Create dataset for flor participants;
data &output_dataset(label="MS #1560 Analysis file (Only FLOR participants) created on &sysdate.");
	set &output_dataset2;

	if flor_dyad;
run;

* Sort the dataset by id;
proc sort data = &output_dataset; by id; run;
proc sort data = &output_dataset2; by id; run;

* print the contents; 
ods rtf file = "&homepath.\code\&job\contents_flor_&sysdate..rtf";
	proc contents data = &output_dataset; 
		ods noproctitle;
	run;
ods rtf close;

* print the contents; 
ods rtf file = "&homepath.\code\&job\contents_all_&sysdate..rtf";
	proc contents data = &output_dataset2; 
		ods noproctitle;
	run;
ods rtf close;

proc printto; run;
