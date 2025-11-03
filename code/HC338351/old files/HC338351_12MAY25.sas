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
					21APR25 - (HC338351) Start file
					22APR25 - add the new derived variables cesd10 and accult_mesa
					05MAY25 - Include the #_all dataset
					08may25 - Updated to include the updates in cont#1(n_hc (v1 and v2) and alcohol_use variables)

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

* Set macro variables; 
%let pw = los_shch;
%let job = HC338351;
%let output_dataset = output.HC338351_flor_&sysdate.;
%let output_dataset2 = output.HC338351_all_&sysdate.;

* Create the dataset HC338351; 
data complete_dt;
	merge invv1.PART_DERV_INV4(keep = STRAT PSU_ID WEIGHT_FINAL_NORM_OVERALL ID CENTER CENTERNUM CLINDATE AGE 
				AGEGROUP_C2 AGEGROUP_C6 GENDER GENDERNUM EDUCATION_C2 EDUCATION_C3
		    	INCOME INCOME_C3 INCOME_C5 POVPCT POVPCT_C4 EMPLOYED YRSUS_C3 HIGH_TRIG LOW_HDL 
				ABDOMINAL_OBESITY_NCEP MARITAL_STATUS BKGRD1_C7 SITE_BKGRD US_BORN YRSUS YRSUS_C2 
				LANG_PREF ACCULT_MESA BMI BMIGRP_C4 BMIGRP_C6 HEIGHT INSULIN_FAST
		   		HOMA_IR CIGARETTE_USE CURRENT_SMOKER DIABETES_SELF DIABETES1 DIABETES2
		    	DIABETES2_INDICATOR DIABETES_LAB DIABETES3 DIAB_DIAG DM_AWARE DM_CONTROL 
		    	DIABETES_C4 HYPERTENSION MED_ANTIDIAB MED_ANTIHYPERT MED_LLD CESD10 STAI10 HEI2010 ALCOHOL_USE N_HC
				AGG_MENT AGG_PHYS pw = &pw)
		invv1.laba_inv4(pw=&pw keep = id laba67 laba68 laba70)
		invv1.sbpa_inv4(pw=&pw keep = id sbpa5 sbpa6 sbpa7)
		invv1.tbea_inv4(pw=&pw keep = id tbea1 tbea3)
		invv1.piea_inv4(pw=&pw keep = id piea4 piea7)
		invv1.ecea_inv4(pw=&pw keep = id ecea2 ecea3 ecea4 ecea5)
		invv1.ocea_inv4(pw=&pw keep = id ocea1 ocea5)
		invv1.anta_inv4(pw=&pw keep = id anta10a)
		invv1.pa_derv_inv4(pw=&pw keep = id weight_pa_ipw_overall acticalyn adherentyn mv_day hrs_day)
		invv2.part_derv_v2_inv3(pw=&pw keep = id age_v2 accult_mesa_v2 cesd10_v2 CLINDATE_V2 YRS_BTWN_V1V2  WEIGHT_NORM_OVERALL_V2 CONSENT_V2 
				GENDER_V2 AGEGROUP_C6_V2 EMPLOYED_V2 EDUCATION_C3_V2 INCOME_C3_V2  LANG_PREF_V2 YRSUS_C3_V2
 				BMI_V2 ABDOMINAL_OBESITY_NCEP_V2 CIGARETTE_USE_V2 INSULIN_FAST_V2 HIGH_TRIG_V2 LOW_HDL_V2 HOMA_IR_V2 
				CURRENT_SMOKER_V2 DIABETES_SELF_V2 DIABETES_LAB_V2 DIABETES3_V2 DM3_AWARE_V2 DM3_CONTROL_V2 n_hc_v2) 
		invv2.rme_v2_inv3(pw=&pw keep = id rme12A rme13A rme19)
		invv2.lab_derv_v2_inv3(pw=&pw keep = id laba67 laba68 laba70 rename=(laba67 = LABA67_v2 laba68 = LABA68_v2 laba70 = LABA70_v2))
		invv2.sbp_v2_inv3(pw=&pw keep = id sbp5 sbp6 sbp7)
		invv2.tbe_v2_inv3(pw=&pw keep = id tbe1 tbe4)
		invv2.ant_v2_inv3(pw=&pw keep = id ant10a)
		flor.flor_part_derv_inv2(in=in_flor pw=&pw keep = id id_child id_dad MODE1 MODE2 AGE_CHILD_ENROLL AGE_CHILD_CLINDATE AGE_CHILD_CLINDATE_MO 
				AGEGRP_CHILD_C4 CLINDATE_FLOR AGE_MOM_FLOR HEIGHT WEIGHT YRS_BTWN_V1FLOR BMIZ WAZ HAZ BMIPCT BMIPCT_C3 BORN_AFTERV2 rename=(HEIGHT=CHILD_HEIGHT WEIGHT=CHILD_WEIGHT))
		flor.demb_inv2(keep = id demb1 demb7-demb11 demb12A demb12B demb13 demb14 demb14A demb15 demb15A demb16)
		;
	by id ;
	
   * FLOR_DYAD;
   if IN_FLOR then FLOR_DYAD = 1; else FLOR_DYAD = 0;
   
   * AGE; 
   If BORN_AFTERV2 = 1 then AGE = AGE_V2;

   * MARITAL_STATUS; 
   If BORN_AFTERV2 = 1 then do;
      If DEMB11 = 1 then MARITAL_STATUS = 1;
      Else if DEMB11 in (2,6) then MARITAL_STATUS = 2;
      Else if DEMB11 in (3,4,5) then MARITAL_STATUS = 3;
   end;
 
   * LABA67;   
   If BORN_AFTERV2 = 1 then LABA67 = LABA67_V2;

   * LABA68; 
   If BORN_AFTERV2 = 1 then LABA68 = LABA68_V2;
  
   * LABA70; 
   If BORN_AFTERV2 = 1 then LABA70 = LABA70_V2;

   * SBPA5; 
   If BORN_AFTERV2 = 1 then SBPA5 = SBP5;

   * SBPA6; 
   If BORN_AFTERV2 = 1 then SBPA6 = SBP6;

   * SBPA7; 
   If BORN_AFTERV2 = 1 then SBPA7 = SBP7;

   * TBEA1; 
   If BORN_AFTERV2 = 1 then TBEA1 = TBE1;

   * TBEA3; 
   If BORN_AFTERV2 = 1 then TBEA3 = TBE4;
  
   * ANTA10A; 
   If BORN_AFTERV2 = 1 then ANTA10A = ANT10A;

   * AGEGROUP_C6; 
   If BORN_AFTERV2 = 1 then AGEGROUP_C6 = AGEGROUP_C6_V2;

   * EMPLOYED; 
   If BORN_AFTERV2 = 1 then EMPLOYED = EMPLOYED_V2;

   * EDUCATION_C3; 
   If BORN_AFTERV2 = 1 and ^MISSING(EDUCATION_C3_V2) then EDUCATION_C3 = EDUCATION_C3_V2;

   * INCOME_C3; 
   If BORN_AFTERV2 = 1 then INCOME_C3 = INCOME_C3_V2;

   * LANG_PREF; 
   If BORN_AFTERV2 = 1 then LANG_PREF = LANG_PREF_V2;

   * YRSUS_C3; 
   If BORN_AFTERV2 = 1 then YRSUS_C3 = YRSUS_C3_V2;

   * BMI;   
   If BORN_AFTERV2 = 1 then BMI = BMI_V2;

   * ABDOMINAL_OBESITY_NCEP;
  If BORN_AFTERV2 = 1 then ABDOMINAL_OBESITY_NCEP = ABDOMINAL_OBESITY_NCEP_V2;

   * CIGARETTE_USE; 
  If BORN_AFTERV2 = 1 then CIGARETTE_USE = CIGARETTE_USE_V2;

   * INSULIN_FAST; 
  If BORN_AFTERV2 = 1 then INSULIN_FAST = INSULIN_FAST_V2;

   * HIGH_TRIG; 
  If BORN_AFTERV2 = 1 then HIGH_TRIG = HIGH_TRIG_V2;

   * LOW_HDL; 
  If BORN_AFTERV2 = 1 then LOW_HDL = LOW_HDL_V2;

   * HOMA_IR; 
  If BORN_AFTERV2 = 1 then HOMA_IR = HOMA_IR_V2;

   * CURRENT_SMOKER; 
  If BORN_AFTERV2 = 1 then CURRENT_SMOKER = CURRENT_SMOKER_V2;

   * DIABETES_SELF; 
  If BORN_AFTERV2 = 1 then DIABETES_SELF = DIABETES_SELF_V2;

   * DIABETES_LAB; 
  If BORN_AFTERV2 = 1 then DIABETES_LAB = DIABETES_LAB_V2;

   * DIABETES3; 
  If BORN_AFTERV2 = 1 then DIABETES3 = DIABETES3_V2;

   * DM_AWARE; 
  If BORN_AFTERV2 = 1 then DM_AWARE = DM3_AWARE_V2;

   * DM_CONTROL; 
  If BORN_AFTERV2 = 1 then DM_CONTROL = DM3_CONTROL_V2;

   * ACCULT_MESA;
  IF BORN_AFTERV2 = 1 and ^missing(ACCULT_MESA_V2) THEN ACCULT_MESA = ACCULT_MESA_V2;

  * CESD10;
  IF BORN_AFTERV2 = 1 and ^missing(CESD10_V2) THEN CESD10 = CESD10_V2;

  * N_HC;
  IF BORN_AFTERV2 = 1 and ^missing(N_HC_V2) THEN N_HC = N_HC_V2;


   * PARITY_V1;
   If RME12A=0 then PARITY_V1=0;
   If RME12A>0 then PARITY_V1 = RME19;

   * PRIMIPARA_V1;
   If PARITY_V1 = 0 THEN PRIMIPARA_V1 = 1;
   If PARITY_V1 > 0 THEN PRIMIPARA_V1 = 0;

   * FGLUCOSE_GE100YN;
   if LABA70 >=100 then FGLUCOSE_GE100YN=1;
   if LABA70 gt .z and  LABA70< 100 then FGLUCOSE_GE100YN=0;

   * BMI_GE30YN;
   if BMI >=30 then BMI_GE30YN=1 ;
   if BMI <30 and BMI gt .z then BMI_GE30YN=0; 

   * SBP_GE120YN;
   if SBPA5 >= 120 then SBP_GE120YN=1;
   if SBPA5 < 120 and SBPA5 gt .z then SBP_GE120YN=0;

   * DBP_GE80YN;
   if SBPA6 >=80 then DBP_GE80YN=1;
   if SBPA6 < 80 and SBPA6 gt .z then DBP_GE80YN=0;

   * HIGHBPYN;
   if SBP_GE120YN = 1 or DBP_GE80YN = 1 then HIGHBPYN=1;
   if SBP_GE120YN = 0 and DBP_GE80YN = 0 then HIGHBPYN=0;

   * BKGRD1_C7NOMISS;
   If 0 <= BKGRD1_C7 <= 6 then BKGRD1_C7NOMISS = BKGRD1_C7;
   If BKGRD1_C7 le .z then BKGRD1_C7NOMISS = 6;

   * EMPLOYEDYN;
   if EMPLOYED in (1,2) then EMPLOYEDYN=0;
   if EMPLOYED in (3,4) then EMPLOYEDYN=1;

  * YRS_BTWN_V1FLOR; 
   If BORN_AFTERV2 = 1 then do;
      YRS_BTWN_V1FLOR = (CLINDATE_FLOR - CLINDATE_V2) / 365.25;
   End;
 
   label
   PARITY_V1	= 'Number of babies born alive by Visit 1'
   PRIMIPARA_V1	= 'FLOR baby is 1st live birth ever (1-yes, 0-no)'
   FGLUCOSE_GE100YN	= 'Fasting glucose >=100 mg/dL'
   BMI_GE30YN	= 'BMI >=30 (obese)'
   SBP_GE120YN	= 'Systolic blood pressure >= 120 mm Hg'
   DBP_GE80YN	= 'Diastolic blood pressure >= 80 mm Hg'
   HIGHBPYN	= 'Systolic blood pressure >= 120 (mm Hg) or diastolic blood pressure >= 80 (mm Hg)'
   BKGRD1_C7NOMISS	= '7-Level Re-classification of Hispanic/Latino Background (Combining Missing with Mixed/Other)'
   EMPLOYEDYN	= 'Employment Status (1-yes, 0-no)'
   FLOR_DYAD  = 'FLOR participant'
   YRS_BTWN_V1FLOR = 'Elapsed time in years between visit 1 and FLOR clinic date' 
   AGE = 'Age' 
	MARITAL_STATUS = 'Marital Status (collapsed categories)' 
	LABA67 = 'Triglycerides (mg/dL) (LABA67)' 
	LABA68 = 'HDL-cholesterol (mg/dL) (LABA68)' 
	LABA70 = 'Glucose, fasting (mg/dL) (LABA70)' 
	SBPA5 = 'Average Systolic (SBPA5)' 
	SBPA6 = 'Average Diastolic (SBPA6)' 
	SBPA7 = 'Average Pulse Rate (SBPA7)' 
	TBEA1 = 'Smoke at least 100 cigs in lifetime (TBEA1)' 
	TBEA3 = 'Present Smoking Status (TBEA3)' 
	ANTA10A = 'Waist Girth (cm) (ANTA10A)' 
	AGEGROUP_C6 = '6-level Age Sub-groups' 
	EMPLOYED = 'Employment Status (includes retirees)' 
	EDUCATION_C3 = 'Education Status (3 levels)' 
	INCOME_C3 = '3-level grouped yearly household income' 
	LANG_PREF = 'Language preference - (1=Span, 2=Eng)' 
	YRSUS_C3 = 'Years lived in the US (50 States, 3-levels)' 
	BMI = 'BMI (kg/m2)' 
	ABDOMINAL_OBESITY_NCEP = 'Abdominal Obesity (waist circ) - NCEP' 
	CIGARETTE_USE = 'Cigarette Use (1-Never,2=Former,3=Current)' 
	INSULIN_FAST = 'Insulin, fasting (calibrated, converted to mU/L)' 
	HIGH_TRIG = 'High Triglycerides (>=150 mg/dL)' 
	LOW_HDL = 'Low HDL (<40 mg/dl (male), <50 mg/dL (females))' 
	HOMA_IR = 'HOMA index of Insulin Resistance' 
	CURRENT_SMOKER = 'Current Smoker (from CIGARETTE_USE)' 
	DIABETES_SELF = 'Diabetes - self report only' 
	DIABETES_LAB = '3-level grouped Diabetes - Lab' 
	DIABETES3 = '3-level grouped Diabetes - ADA Guidelines plus self-reported diabetes diagnosis' 
	DM_AWARE = 'Diabetes awareness at baseline' 
	DM_CONTROL = 'Diabetes controlled: DM Classified at Baseline and A1C < 7%' 
	ACCULT_MESA = "Acculturation Score - MESA" 
	CESD10 = "10-item CESD10"	
	N_HC = "Health Insurance Coverage - Current"
;
run;

* Create dataset for flor participants;
data &output_dataset(label="MS #1560 Analysis File (ONLY FLOR participants) created in &job on &sysdate.");
	merge complete_dt hc3383.hc338301_flor(keep=id pce: BIRTHWT_GA_Z BIRTHWT_GA_PCT BABY1YN DAYSV1BIRTH YRSV1BIRTH BIRTHWT_C3 LGA SGA PRETERM BIRTH_ORDER); * no access to conf data. It uses the analytic file to bring those variables;
	by id;
	if flor_dyad;
run;

                                     

* Create dataset for all participants with a baby, even those w/o participation in flor; 
proc sql;
	create table output_dataset2 as
	select *
	from complete_dt
	where id in (select distinct(id) 
				  from hc3383.hc338301_all); 
quit;

data &output_dataset2(label="All 1st live singleton births between V1 & V2 created in &job on &sysdate.");
	merge output_dataset2 hc3383.hc338301_all(keep=id pce: BIRTHWT_GA_Z BIRTHWT_GA_PCT BABY1YN DAYSV1BIRTH YRSV1BIRTH BIRTHWT_C3 LGA SGA PRETERM BIRTH_ORDER);
	by id;
	if missing(born_afterv2) then born_afterv2 = 0;
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
