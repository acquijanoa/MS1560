******************************************************************
  REQUEST:       HC3383

  TITLE:         MS #1560 �Association of preconception socio-behavioral factors and child�s weight� by Siega-Riz

  DESCRIPTION:   -  Create an analytic data file for MS #1560 � �Association of preconception socio-behavioral factors 
                   and child�s weight in the HCHS/SOL study� [Grant�s aim #2]
                 -  The statistical analyses and tables will be done by GRA Alvaro under Daniela�s supervision.

  MANUSCRIPT:    HCM1560

  PROGRAMMER:    Dan Piston

  REQUESTOR:     Daniela Sotres/Alvaro Quijano

  DATE:          4/23/2025
-----------------------------------------------------------------
  JOB NUMBER:    HC338301

  DESCRIPTION:   Create analytic file for MS #1560
            
  LANGUAGE:      SAS VERSION 9.4

  HISTORY:       HC338301 4/23/2025 - uccdjp - original request
                 HC338301 5/6/2025 - uccdjp Cont #1 - Bring the variables ALCOHOL_USE, N_HC and N_HC_V2. 
                    - It also requires updating the variable EDUCATION_C3 to avoid overwriting actual values 
                      with missing data.
                 HC338301 6/23/25 - uccdjp Cont #2 - 
                    1.  Derive variables PCT_MVPA, INCOME_C2  and HEI2010_C3
                    2.  Bring variables YRSV1BIRTH, DAYSV1BIRTH, BIRTHWT_GA_Z from PCE_DERV
                    3.  Bring sleep-related variables from PART_DERV_INV4
				 HC338301 12/8/25 - aqa Cont #3 -
					1.   Derive variable SLPDUR_LT8HRS, KEEP_MS1560 and PRS_COMPLETE
					2.   Bring variable CHILD_PRS_BMI_A
					3.   Bring variables PAG2008YN and PAG2008YN_BOUT from PA_DERV_INV4
					4.   Update &prog

  NOTE:          Related: HC3139 � MS1207 [FLOR grant aim #1] Uses final INV1 data and MI
-----------------------------------------------------------------
  INPUT:         J:\HCHS\SC\Sasdata\INV_Use\Consolidated\PART_DERV_INV4
                                                         LABA_INV4
                                                         SBPA_INV4
                                                         TBEA_INV4
                                                         PIEA_INV4
                                                         ECEA_INV4
                                                         OCEA_INV4
                                                         ANTA_INV4
                                                         PA_DERV_INV4

                J:\HCHS\SC\Sasdata\Visit2\INV_Use\Consolidated\PART_DERV_V2_INV3
                                                               RME_V2_INV3
                                                               LAB_DERV_V2_INV3
                                                               SBP_V2_INV3
                                                               TBE_V2_INV3
                                                               ANT_V2_INV3
                                                               pce_derv_v2_inv3

                J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\INV_Use\Datasets\FLOR_PART_DERV_INV2
                                                                       DEMB_INV2
                
  OUTPUT:       J:\HCHS\SC\Sasdata\Scmisc\HC338301_FLOR
                                          HC338301_ALL
                    via &mylib -> Review
 
*------------------------------------------------------------------

*******************************************************************;

OPTIONS ps=59 ls=173 nodate nonumber MPRINT errors=50  orientation=landscape;
%let prog = AQA;
%let req = HC3383;
%let job = &req.01;
footnote "Job &job run by &prog on &SYSDATE at &SYSTIME";

libname confid 'J:\HCHS\SC\Confid\Sasdata\Visit2\Internal_Use';
/*libname cons 'J:\HCHS\SC\Sasdata\INV_Use\Consolidated';*/
libname cons 'J:\HCHS\SC\Sasdata\INV_Use\INV4_Archive12';
libname consv2 'J:\HCHS\SC\Sasdata\Visit2\INV_Use\Consolidated';
libname flor 'J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\INV_Use\Datasets';
libname floriu "J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\Internal_Use";
libname encrp "J:\HCHS\SC\SASDATA\Encrypted_IDs";
libname transid 'J:\HCHS\SC\SASDATA\Transfer_IDS';


%let home = J:\HCHS\STATISTICS\GRAS\QAngarita\Manuscripts\MS1560\SC\Continuation #3;
libname mylib "&home.";


* Keep ONLY the 1st pregnancy that resulted in a live birth after visit 1 (PCE3=1);
* PCE3 = Pregnancy Result;
* PCE1A = Pregnancy Number;

/* PCE_DERV_V2_INV3 does not have PCE3 - need it from here, BABY1YN from derv */
data pce_comb;
    merge consv2.pce_derv_v2_inv3
          consv2.pce_v2_inv3
    ;
    by id;
run;

proc sort data=pce_comb(where = (PCE3=1)) out=PCE_V2_INV3;
   by ID PCE1A;
run;

proc contents data=PCE_V2_INV3; run;

data PCE_COMB_V2_INV3;
    set PCE_V2_INV3;
    by ID PCE1A;
    if first.ID;
    drop
/*       PCE0B */
/*       PCE1BD */
/*       PCE1BM */
       PCE1BY 
/*       EVENT*/
/*       EVENTNAME*/
       FORM
/*       FORMSTATUS_PCE*/
       OCCURRENCE
       VERS
       VISIT
    ;
run;

title 'pce_v2_inv3 and pce_derv_v2_inv3 combined Contents';
proc contents data=pce_v2_inv3; run;
title;

/* Cont #2 PCE - request section B.1.q */
data pce_cont2;
    set consv2.pce_derv_v2_inv3(where=(BABY1YN=1));

    /*
    1 record per pregnancy between V1 & V2 (i.e., file has multiple records per SUBJECTID)
we want to keep ONLY the 1st pregnancy that resulted in a live birth after visit 1 (BABY1YN=1)
    */
    keep ID BABY1YN DAYSV1BIRTH YRSV1BIRTH BIRTHWT_GA_Z;
run;
proc sort data=pce_cont2 out=cont2_check nodupkey; by id; run; /* only 1 birth per id anyway so cool */


/* Cont #3 */

%MACRO ANONYMIZE_DB(DATA, OUT);
	PROC SORT DATA=TRANSID.transfer_ids out=transfer_ids; BY SUBJECTID; RUN;
	DATA TRANSFER0(DROP=SUBJECTID);
		MERGE TRANSFER_IDS(KEEP=SUBJECTID TRANSFERID IN=A) 
			ENCRP.MASTER_ENCRYPTION_FILE_INV3V1(KEEP=SUBJID ID RENAME=(SUBJID=SUBJECTID));
		BY SUBJECTID;	
		IF A;
	RUN;
	DATA ENCRYPTO;
		SET ENCRP.MASTER_ENCRYPTION_FILE_INV3V1(KEEP=SUBJID ID RENAME=(SUBJID=SUBJECTID))
		TRANSFER0(KEEP=TRANSFERID ID RENAME=(TRANSFERID=SUBJECTID));
	RUN;			
	PROC SORT DATA=ENCRYPTO OUT=ENCRYPT; BY SUBJECTID;RUN; 
  	DATA DATASET; SET &DATA; RUN;
  	DATA &OUT;
    	MERGE ENCRYPT(KEEP=SUBJECTID ID)
          DATASET(IN=A);
    	BY SUBJECTID;
	  	DROP SUBJECTID;
    	IF A;
  	RUN;
    PROC SORT DATA=&OUT OUT=&OUT; BY ID; RUN;
%MEND ANONYMIZE_DB;

* Mask the subject's IDs in the IU dataset;
%anonymize_db(data = floriu.flor_grs_child_iu2(keep=subjectid child_prs_bmi_a), 
				out = flor_grs_child_iu2);


data combine;
    merge cons.PART_DERV_INV4 (pw=los_shch
                               keep = strat psu_id weight_final_norm_overall
                                      id center centernum clindate
                                      age agegroup_c2 agegroup_c6 gender gendernum education_c2 education_c3 income income_c3 
                                      income_c5 POVPCT POVPCT_C4 employed YRSUS_C3 HIGH_TRIG LOW_HDL ABDOMINAL_OBESITY_NCEP 
                                      Marital_Status N_HC
                                      bkgrd1_c7 site_bkgrd us_born yrsus yrsus_c2 LANG_PREF ACCULT_MESA
                                      bmi bmigrp_c4 bmigrp_c6 height insulin_fast
                                      homa_ir cigarette_use current_smoker diabetes_self diabetes1 diabetes2 diabetes2_indicator 
                                      diabetes_lab diabetes3 diab_diag dm_aware dm_control diabetes_c4 hypertension ALCOHOL_USE
                                      med_antidiab med_antihypert med_lld  
                                      CESD10 STAI10 HEI2010 AGG_MENT AGG_PHYS 
                                      SLPDUR SLPDUR_WKDAY SLPDUR_WKEND )
          cons.LABA_INV4 (pw=los_shch keep = id LABA67 LABA68 LABA70 )
          cons.SBPA_INV4 (pw=los_shch keep = id SBPA5 SBPA6 SBPA7 )
          cons.TBEA_INV4 (pw=los_shch keep = ID TBEA1 TBEA3 )
          cons.PIEA_INV4 (pw=los_shch keep = ID PIEA4 PIEA7 )
          cons.ECEA_INV4 (pw=los_shch keep = ID ECEA2 ECEA3 ECEA4 ECEA5 )
          cons.OCEA_INV4 (pw=los_shch keep = ID OCEA1 OCEA5 )
          cons.ANTA_INV4 (pw=los_shch keep = ID ANTA10a )
          cons.PA_DERV_INV4 (keep = ID WEIGHT_PA_IPW_OVERALL ACTICALYN ADHERENTYN MV_DAY HRS_DAY PAG2008YN PAG2008YN_BOUT)
          consv2.PART_DERV_V2_INV3 (keep = ID clindate_v2 yrs_btwn_v1v2 weight_norm_overall_v2 consent_v2
                                         age_v2 gender_v2 AGEGROUP_C6_V2 EMPLOYED_V2 EDUCATION_C3_V2 INCOME_C3_V2 N_HC_V2 
                                         LANG_PREF_V2 YRSUS_C3_V2
                                         BMI_V2 ABDOMINAL_OBESITY_NCEP_V2
                                         CIGARETTE_USE_V2 INSULIN_FAST_V2 HIGH_TRIG_V2 LOW_HDL_V2 
                                         HOMA_IR_V2 CURRENT_SMOKER_V2 DIABETES_SELF_V2 DIABETES_LAB_V2 DIABETES3_V2 
                                         DM3_AWARE_V2 DM3_CONTROL_V2
                                         ACCULT_MESA_V2 CESD10_V2 )
          consv2.RME_V2_INV3 (keep = ID RME12A RME13A RME19 )
          consv2.LAB_DERV_V2_INV3 (keep = ID LABA67 LABA68 LABA70 
                                   rename = (LABA67 = LABA67_V2 LABA68 = LABA68_V2 LABA70 = LABA70_V2) )
          consv2.SBP_V2_INV3 (keep = ID SBP5 SBP6 SBP7 )
          consv2.TBE_V2_INV3 (keep = ID TBE1 TBE4 )
          consv2.ANT_V2_INV3 (keep = ID ANT10A )
          PCE_COMB_V2_INV3
          flor.FLOR_PART_DERV_INV2 (keep = ID ID_CHILD ID_DAD MODE1 MODE2
                                           AGE_CHILD_ENROLL AGE_CHILD_CLINDATE AGE_CHILD_CLINDATE_MO AGEGRP_CHILD_C4 CLINDATE_FLOR
                                           AGE_MOM_FLOR HEIGHT WEIGHT
                                           YRS_BTWN_V1FLOR
                                           BMIZ WAZ HAZ BMIPCT BMIPCT_C3 BORN_AFTERV2
                                    rename = (HEIGHT=CHILD_HEIGHT WEIGHT = CHILD_WEIGHT)
                                    in=inflor)
          flor.DEMB_INV2 (keep = ID DEMB1 DEMB7-DEMB11 DEMB12A DEMB12B DEMB13 DEMB14 DEMB14A DEMB15 DEMB15A DEMB16)
		  flor_grs_child_iu2
          pce_cont2
    ;
    by ID;

    * BORN_AFTERV2 recode for continuation 1;
    if missing(BORN_AFTERV2) then BORN_AFTERV2 = 0;

    * PARITY_V1;
    If RME12A=0 then PARITY_V1=0;
    If RME12A>0 then PARITY_V1 = RME19;

    * PRIMIPARA_V1;
    If PARITY_V1 = 0 THEN PRIMIPARA_V1 = 1;
    If PARITY_V1 > 0 THEN PRIMIPARA_V1 = 0;

    * FGLUCOSE_GE100YN;
    If BORN_AFTERV2 = 0 then do;
        if LABA70 >=100 then FGLUCOSE_GE100YN = 1;
        Else if .z < LABA70 < 100 then FGLUCOSE_GE100YN = 0;
    End;
    Else do;
        if LABA70_V2 >=100 then FGLUCOSE_GE100YN = 1;
        Else if .z < LABA70_V2 < 100 then FGLUCOSE_GE100YN = 0;
    End;

    * BMI_GE30YN;
    If BORN_AFTERV2 = 0 then do;
        if BMI >=30 then BMI_GE30YN=1 ;
        if .z < BMI <30 then BMI_GE30YN=0; 
    End;
    Else do;
        if BMI_V2 >=30 then BMI_GE30YN = 1;
        Else if .z < BMI_v2 <30  then BMI_GE30YN = 0;
    End;

    * SBP_GE120YN;
    If BORN_AFTERV2 = 0 then do;
        if SBPA5 >= 120 then SBP_GE120YN=1;
        if .z < SBPA5 < 120 then SBP_GE120YN=0;
    End;
    Else do;
        if SBP5 >= 120 then SBP_GE120YN = 1;
        Else if .z < SBP5 < 120 then SBP_GE120YN = 0;
    End;

    * DBP_GE80YN;
    If BORN_AFTERV2 = 0 then do;
    if SBPA6 >=80 then DBP_GE80YN=1;
    if .z < SBPA6 < 80 then DBP_GE80YN=0;
    End;
    Else do;
    if SBP6 >=80 then DBP_GE80YN = 1;
    Else if .z < SBP6 < 80 then DBP_GE80YN = 0;
    End;

    * HIGHBPYN;
    if SBP_GE120YN = 1 or DBP_GE80YN = 1 then HIGHBPYN=1;
    if SBP_GE120YN = 0 and DBP_GE80YN = 0 then HIGHBPYN=0;

    * BKGRD1_C7NOMISS;
    If 0 <= BKGRD1_C7 <= 6 then BKGRD1_C7NOMISS = BKGRD1_C7;
    If BKGRD1_C7 le .z then BKGRD1_C7NOMISS = 6;

    * EMPLOYEDYN;
    If BORN_AFTERV2 = 0 then do;
        if EMPLOYED in (1,2) then EMPLOYEDYN=0;
        if EMPLOYED in (3,4) then EMPLOYEDYN=1;
    End;
    Else do;
        if EMPLOYED_V2 in (1,2) then EMPLOYEDYN = 0;
        Else if EMPLOYED_V2 in (3,4) then EMPLOYEDYN = 1;
    End;

    * FLOR_DYAD;
    If inflor then FLOR_DYAD = 1;
    Else FLOR_DYAD = 0;

    * added for continuation 1 on 8-9-24;
    * YRS_BTWN_V1FLOR; 
    If BORN_AFTERV2 = 1 then do;
        YRS_BTWN_V1FLOR = (CLINDATE_FLOR - CLINDATE_V2) / 365.25;
    End;

    * AGE; 
    If BORN_AFTERV2 = 1 then AGE = AGE_V2;

    * MARITAL_STATUS; 
    If BORN_AFTERV2 = 1 then do;
    If DEMB11 = 1 then MARITAL_STATUS = 1;
    Else if DEMB11 in (2,6) then MARITAL_STATUS = 2;
    Else if DEMB11 in (3,4,5) then MARITAL_STATUS = 3;
    End;

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
    If BORN_AFTERV2 = 1 and ^missing(EDUCATION_C3_V2) then EDUCATION_C3 = EDUCATION_C3_V2;

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
    IF BORN_AFTERV2 = 1 THEN ACCULT_MESA = ACCULT_MESA_V2;
        /* ELSE ACCULT_MESA; (keep the same, don't overwrite) */

    * CESD10;
    IF BORN_AFTERV2 = 1 THEN CESD10 = CESD10_V2;
        /* ELSE CESD10; */

    * N_HC;
    IF BORN_AFTERV2 = 1 and ^missing(N_HC_V2) THEN  N_HC = N_HC_V2;
        /* ELSE N_HC; */

    * PCT_MVPA;
    if hrs_day ne 0 and ^missing(mv_day) and ^missing(hrs_day) then PCT_MVPA = MV_DAY / HRS_DAY;
    else PCT_MVPA = .;

    * INCOME_C2;
    if INCOME_C3 = 3 then INCOME_C2 = .;
    else INCOME_C2 = INCOME_C3;

    * HEI2010_C3;
    if missing(HEI2010) then HEI2010_C3 = .;
    else if HEI2010 <= 50.1 then HEI2010_C3 = 1;
    else if HEI2010 > 50.1 AND HEI2010 <= 62.5 then HEI2010_C3 = 2;
    else if HEI2010 > 62.5 then HEI2010_C3 = 3;

	* SLPDUR_LT8HRS;
	if missing(slpdur) then SLPDUR_LT8HRS = .;
	else if slpdur < 8 then SLPDUR_LT8HRS = 1;
	else SLPDUR_LT8HRS = 0; 

	* PRS_COMPLETE;
	if FLOR_DYAD AND ^MISSING(CHILD_PRS_BMI_A) then PRS_COMPLETE = 1;
	else PRS_COMPLETE = 0;

	* KEEP_MS1560;
	if FLOR_DYAD=0 OR MISSING(CHILD_WEIGHT) OR MISSING(CHILD_HEIGHT) then KEEP_MS1560 = 0;
	else KEEP_MS1560 = 1;

	* BMIPCT_C2;
	if BMIPCT_C3 in (2,3) then BMIPCT_C2 = 1;
	else if BMIPCT_C3 = 1 then BMIPCT_C2 = 0;
	else BMIPCT_C2 = .;

    label
        PARITY_V1 = 'Number of babies born alive by Visit 1' 
        PRIMIPARA_V1 = 'FLOR baby is 1st live birth ever (1-yes, 0-no)' 
        FGLUCOSE_GE100YN = 'Fasting glucose >=100 mg/dL' 
        BMI_GE30YN = 'BMI >=30 (obese)' 
        SBP_GE120YN = 'Systolic blood pressure >= 120 mm Hg' 
        DBP_GE80YN = 'Diastolic blood pressure >= 80 mm Hg' 
        HIGHBPYN = 'Systolic blood pressure >= 120 (mm Hg) or diastolic blood pressure >= 80 (mm Hg)' 
        BKGRD1_C7NOMISS = '7-Level Re-classification of Hispanic/Latino Background (Combining Missing with Mixed/Other)' 
        EMPLOYEDYN = 'Employment Status (1-yes, 0-no)' 
        FLOR_DYAD = 'FLOR participant' 
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
        ACCULT_MESA = 'Acculturation Score - MESA'
        CESD10 = '10-item CESD10'
        N_HC = 'Health Insurance Coverage - Current'
        PCT_MVPA = 'Percentage of time spent in moderate-to-vigorous physical activity'
        INCOME_C2 = '2-level grouped yearly household income'
        HEI2010_C3 = '3-level Health Index Score 2010'
		SLPDUR_LT8HRS = 'Sleep duration (less than 8 hours)'
		KEEP_MS1560 = 'Flag - FLOR dyad and complete child anthropometry'
		PRS_COMPLETE = 'Flag - child BMI polygenic risk score is complete'
		BMIPCT_C2 = 'Respondent is overweight or obese';
    ;
run;


data HC338301_FLOR;
    set combine;
    if FLOR_DYAD;
run;

data HC338301_ALL;
    set combine;
    if FLOR_DYAD or (BABY1YN=1 and PCE3A=1);
run;

* write to folder;
proc sort data=HC338301_FLOR out=mylib.HC338301_FLOR(label="MS #1560 Analysis File (ONLY FLOR participants) created in &job on &SYSDATE");
    by ID;
run;

proc sort data=HC338301_ALL out=mylib.HC338301_ALL(label="All 1st live singleton births between V1 & V2 created in &job on &SYSDATE");
    by ID;
run;

* q/a;

proc print data=mylib.HC338301_FLOR(obs=5);
title 'Top 5 obs for HC338101_FLOR.sas7bdat';
run;

proc print data=mylib.HC338301_ALL(obs=5);
title 'Top 5 obs for HC338101_ALL.sas7bdat';
run;

title;
title "Freq for derived variables in HC338101_FLOR.sas7bdat";
proc freq data=mylib.HC338301_FLOR;
   tables
   RME12A*RME19 * PARITY_V1
   PARITY_V1*PRIMIPARA_V1
   BORN_AFTERV2*LABA70* laba70_v2*FGLUCOSE_GE100YN
   BORN_AFTERV2*BMI*bmi_v2*BMI_GE30YN
   BORN_AFTERV2*SBPA5*SBP_GE120YN
   BORN_AFTERV2*SBPA6* sbp6 *DBP_GE80YN
   SBP_GE120YN*DBP_GE80YN*HIGHBPYN
   BKGRD1_C7*BKGRD1_C7NOMISS
   EMPLOYED*employed_v2*EMPLOYEDYN
   BORN_AFTERV2*CLINDATE_FLOR*CLINDATE_V2*YRS_BTWN_V1FLOR
   BORN_AFTERV2*AGE
   BORN_AFTERV2 * DEMB11 * MARITAL_STATUS
   BORN_AFTERV2 * LABA67_V2 * LABA67
   BORN_AFTERV2 * LABA68_V2 * LABA68
   BORN_AFTERV2 * LABA70_V2 * LABA70
   BORN_AFTERV2 * SBP5 * SBPA5
   BORN_AFTERV2 * SBP6 *SBPA6
   BORN_AFTERV2 * SBP7 *SBPA7
   BORN_AFTERV2 * tbe1 * TBEA1
   BORN_AFTERV2 * tbe4 * TBEA3
   BORN_AFTERV2 * ANT10A* ANTA10A
   BORN_AFTERV2 * AGEGROUP_C6_V2 * AGEGROUP_C6
   BORN_AFTERV2 * EMPLOYED_V2 * EMPLOYED
   BORN_AFTERV2 * EDUCATION_C3_V2 * EDUCATION_C3
   BORN_AFTERV2 * INCOME_C3_V2* INCOME_C3
   BORN_AFTERV2 * LANG_PREF_V2* LANG_PREF
   BORN_AFTERV2 * YRSUS_C3_V2 * YRSUS_C3
   BORN_AFTERV2 *  BMI_V2 *  BMI 
   BORN_AFTERV2 *  ABDOMINAL_OBESITY_NCEP_V2*ABDOMINAL_OBESITY_NCEP 
   BORN_AFTERV2 * CIGARETTE_USE_V2* CIGARETTE_USE 
   BORN_AFTERV2 * INSULIN_FAST_V2 * INSULIN_FAST 
   BORN_AFTERV2 * HIGH_TRIG_V2 * HIGH_TRIG
   BORN_AFTERV2 * LOW_HDL_V2 * LOW_HDL 
   BORN_AFTERV2 * HOMA_IR_V2 * HOMA_IR
   BORN_AFTERV2 * CURRENT_SMOKER * CURRENT_SMOKER_V2
   BORN_AFTERV2 * DIABETES_SELF_V2 * DIABETES_SELF 
   BORN_AFTERV2 * DIABETES_LAB_V2 * DIABETES_LAB
   BORN_AFTERV2 * DIABETES3_V2 * DIABETES3
   BORN_AFTERV2 * DM3_AWARE_V2 * DM_AWARE
   BORN_AFTERV2 * DM3_CONTROL_V2 * DM_CONTROL 
   /list missing
   ;
run;

title "Freq for derived variables in HC338101_ALL.sas7bdat";
proc freq data=mylib.HC338301_ALL;
   tables
   RME12A*RME19 * PARITY_V1
   PARITY_V1*PRIMIPARA_V1
   BORN_AFTERV2*LABA70* laba70_v2*FGLUCOSE_GE100YN
   BORN_AFTERV2*BMI*bmi_v2*BMI_GE30YN
   BORN_AFTERV2*SBPA5*SBP_GE120YN
   BORN_AFTERV2*SBPA6* sbp6 *DBP_GE80YN
   SBP_GE120YN*DBP_GE80YN*HIGHBPYN
   BKGRD1_C7*BKGRD1_C7NOMISS
   EMPLOYED*employed_v2*EMPLOYEDYN
   BORN_AFTERV2*CLINDATE_FLOR*CLINDATE_V2*YRS_BTWN_V1FLOR
   BORN_AFTERV2*AGE
   BORN_AFTERV2 * DEMB11 * MARITAL_STATUS
   BORN_AFTERV2 * LABA67_V2 * LABA67
   BORN_AFTERV2 * LABA68_V2 * LABA68
   BORN_AFTERV2 * LABA70_V2 * LABA70
   BORN_AFTERV2 * SBP5 * SBPA5
   BORN_AFTERV2 * SBP6 *SBPA6
   BORN_AFTERV2 * SBP7 *SBPA7
   BORN_AFTERV2 * tbe1 * TBEA1
   BORN_AFTERV2 * tbe4 * TBEA3
   BORN_AFTERV2 * ANT10A* ANTA10A
   BORN_AFTERV2 * AGEGROUP_C6_V2 * AGEGROUP_C6
   BORN_AFTERV2 * EMPLOYED_V2 * EMPLOYED
   BORN_AFTERV2 * EDUCATION_C3_V2 * EDUCATION_C3
   BORN_AFTERV2 * INCOME_C3_V2* INCOME_C3
   BORN_AFTERV2 * LANG_PREF_V2* LANG_PREF
   BORN_AFTERV2 * YRSUS_C3_V2 * YRSUS_C3
   BORN_AFTERV2 *  BMI_V2 *  BMI 
   BORN_AFTERV2 *  ABDOMINAL_OBESITY_NCEP_V2*ABDOMINAL_OBESITY_NCEP 
   BORN_AFTERV2 * CIGARETTE_USE_V2* CIGARETTE_USE 
   BORN_AFTERV2 * INSULIN_FAST_V2 * INSULIN_FAST 
   BORN_AFTERV2 * HIGH_TRIG_V2 * HIGH_TRIG
   BORN_AFTERV2 * LOW_HDL_V2 * LOW_HDL 
   BORN_AFTERV2 * HOMA_IR_V2 * HOMA_IR
   BORN_AFTERV2 * CURRENT_SMOKER * CURRENT_SMOKER_V2
   BORN_AFTERV2 * DIABETES_SELF_V2 * DIABETES_SELF 
   BORN_AFTERV2 * DIABETES_LAB_V2 * DIABETES_LAB
   BORN_AFTERV2 * DIABETES3_V2 * DIABETES3
   BORN_AFTERV2 * DM3_AWARE_V2 * DM_AWARE
   BORN_AFTERV2 * DM3_CONTROL_V2 * DM_CONTROL 
   PCT_MVPA
    INCOME_C2 
    HEI2010_C3
   /list missing
   ;
run;

title;
ods rtf file = "&home.\Proc contents for MS1560 Analysis File FLOR.rtf";
   proc contents data=mylib.HC338301_FLOR;
   run;
ods rtf close;

ods rtf file = "&home.\Proc contents for MS1560 Analysis File ALL.rtf";
   proc contents data=mylib.HC338301_ALL;
   run;
ods rtf close;
run;
