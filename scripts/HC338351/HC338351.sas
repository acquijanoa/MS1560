%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\Manuscripts\MS1560;
proc printto log="&homepath.\scripts\HC338351\HC338351_&sysdate..log" 
	print = "&homepath.\scripts\HC338351\HC338351_&sysdate..lst" new; 
run;

/*********************************************************
*                                                         *
*  SAS PROGRAM - QC DATASET JOB HC3383 					         *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338351.sas
*                                       
*  PROGRAMMER: �lvaro Quijano (AQ)
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
			03nov25 - derive variables SLP_DUR_LT8HRS
			04nov25 - add flags to indicate completeness of child_prs_bmi and child anthropometry
					  bring PAG2008YN and PAG2008YN_BOUT from PA_DERV_INV5
			12nov25 - rename anthro_child_complete to keep_ms1560
							  
* ----------------------------------------------------------
*
*  INPUT: HC338301_all (from J:\HCHS\SC\Review\HC3383)
			flor_grs_child_iu2 (from J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\Internal_Use)
*                                        
*  OUTPUT: HC338351_flor_&sysdate.
			HC338351_all_&sysdate.
*
**********************************************************/
options orientation = landscape nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 

* Set libraries name; 
libname invv1 "J:\HCHS\SC\Sasdata\INV_Use\Consolidated";
libname invv2 "J:\HCHS\SC\Sasdata\Visit2\INV_Use\Consolidated";
libname flor "J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\INV_Use\Datasets";
libname confid 'J:\HCHS\SC\Confid\Sasdata\Visit2\Internal_Use';
libname output "&homepath.\data";
libname hc3383 "J:\HCHS\SC\Review\HC3001-HC4000\HC3383";
libname floriu "J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\Internal_Use";

proc contents data=floriu.FLOR_PART_DERV_IU2; run; quit;

proc means data = floriu.FLOR_PART_DERV_IU2 mean q1 median q3 min max ;
	var bmiz ;
run; quit;

* include macros;
%include "&homepath.\scripts\HC338391\HC3383_anonymize_db.sas";

* Set macro variables; 
%let pw = los_shch;
%let job = HC338351;

* Define the output dataset names;
%let output_dataset = output.HC338351_flor_&sysdate.;
%let output_dataset2 = output.HC338351_all_&sysdate.;

* Mask the subject's IDs in the IU dataset;
%anonymize_db(data = floriu.flor_grs_child_iu2(keep=subjectid child_prs_bmi_a), 
				out = flor_grs_child_iu2);

* Derive and bring variables of interest;
data &output_dataset2(label="All 1st live singleton births between V1 & V2 created on &sysdate.");
	merge hc3383.hc338301_all(in=in_hc3383) 
			flor_grs_child_iu2
			invv1.pa_derv_inv5(keep=id pag2008yn pag2008yn_bout);
	by id;

	* SLPDUR_LT8HRS;
	if missing(SLPDUR) then SLPDUR_LT8HRS = .;
	else if SLPDUR < 8 then SLPDUR_LT8HRS = 1;
	else SLPDUR_LT8HRS = 0;
	label SLPDUR_LT8HRS = 'Sleep duration (<8 hours)';

	* KEEP_MS1560;
	if ^missing(child_weight) or ^missing(child_height) then KEEP_MS1560 = 1;
	else KEEP_MS1560 = 0;
	label KEEP_MS1560 = "Flag - FLOR dyad and complete child anthropometry";

	* PRS_BMI_COMPLETE;
	if ^missing(child_prs_bmi_a) then PRS_COMPLETE = 1;
	else PRS_COMPLETE=0;
	label PRS_COMPLETE="Flag - child BMI polygenic risk score is complete";

	* Include people in the the *_all file;
	if IN_HC3383;
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
ods rtf file = "&homepath.\scripts\&job\contents_flor_&sysdate..rtf";
	proc contents data = &output_dataset; 
		ods noproctitle;
	run;
ods rtf close;

* print the contents; 
ods rtf file = "&homepath.\scripts\&job\contents_all_&sysdate..rtf";
	proc contents data = &output_dataset2; 
		ods noproctitle;
	run;
ods rtf close;

proc printto; run;
