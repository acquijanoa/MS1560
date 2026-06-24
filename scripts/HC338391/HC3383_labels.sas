/*

	Program name: HC3383_labels.sas

	Programmer: Alvaro Quijano

	Description: Macro that includes the labels to create a proc report

	Version control:	10jun25:	update POVPCT label
						18nov25:    update labels of SLPDUR and HEI2010_C3 to 
										include units and tertiles, respectively
						24jun26:    update CHILD_PRS_BMI_A label

*/


%MACRO labels();
	attrib label length = $ 150  
			model length = $ 10;

	* categorize the p-value into 4 levels;
	if probt <= 0.01 then pv = 1; 
	else if probt > 0.01 and probt <= 0.05 then pv = 2;
	else if probt > 0.05 and probt <= 0.1 then pv = 3;
	else if probt > 0.1 and probt <= 0.2 then pv = 4;
	else if probt >= 0.2 then pv = 5; 

	* Sntadrd error negative to be formatted within parenthesis;
	std = -1 * stderr;

	* Model 1 variables;
	if variable = 'AGE' then do; label = "{\b Maternal age (years) \b0 \li250}"; order = 1; end;
	if variable = 'BKGRD1_C7NOMISS_MEXICAN' THEN DO; LABEL = "{\b Hispanic/Latino Background \b0 \line \li250   Mexican}"; ORDER = 2; ESTIMATE = 99; STD = 99; pv = 5; END;
	if variable = 'BKGRD1_C7NOMISS_P_RICAN' THEN DO; LABEL = "^S={indent=2mm} Puerto Rican"; ORDER = 2.1; END; 
	if variable = 'BKGRD1_C7NOMISS_CUBAN' THEN DO; LABEL = "^S={indent=2mm} Cuban"; ORDER = 2.2; END;
	if variable = 'BKGRD1_C7NOMISS_DOMINICAN' THEN DO; LABEL = "^S={indent=2mm} Dominican"; ORDER = 2.3; END;
	if variable = 'BKGRD1_C7NOMISS_C_AMERICAN' THEN DO; LABEL = "^S={indent=2mm} Central American"; ORDER = 2.4; END;
	if variable = 'BKGRD1_C7NOMISS_SOUTH' THEN DO; LABEL = "^S={indent=2mm} South American"; ORDER = 2.5; END;
	if variable = 'BKGRD1_C7NOMISS_BK_OTHER' THEN DO; LABEL = "^S={indent=2mm} Other heritage"; ORDER = 2.6; END;
	if variable = 'BKGRD1_C7NOMISS_CARIBBEAN' THEN DO; LABEL = "^S={indent=2mm} Caribbean"; ORDER = 2.1; END; 
	if variable = 'BKGRD1_C7NOMISS_SC_OTHER' THEN DO; LABEL = "^S={indent=2mm} Central and South America/Other"; ORDER = 2.2; END;
	if variable = "N_HC_NO" THEN DO; LABEL = "{\b Health Insurance \line \b0 \li250   No}"; ORDER=3; ESTIMATE = 99; STD=99; pv = 5; END;
	if variable = "N_HC_YES" THEN DO; LABEL = "^S={indent=2mm} Yes"; ORDER=3.1; END; 
	if variable = 'EDUCATION_C3_N_HIGHSCHOOL_GED' then do; label = "{\b Education \b0 \line \li250   Less than high school}"; order = 4; ESTIMATE = 99; STD = 99; pv = 5; end;
	if variable = 'EDUCATION_C3_AT_MOST_HIGHSCHOOL_GED' then do; label = "^S={indent=2mm} High school"; order = 4.1; end;
	if variable = 'EDUCATION_C3_G_HIGHSCHOOL' then do; label = "^S={indent=2mm} Greater than high school"; order = 4.2; end;
	if variable = 'EMPLOYEDYN_NOT_EMPLOYED' then do; label = "{\b Employment status \b0 \line \li250   Not employed}"; order = 5; estimate=99; std = 99; pv = 5; end;
	if variable = 'EMPLOYEDYN_EMPLOYED' then do; label = "^S={indent=2mm} Employed"; order = 5.1; end;
	if variable = 'INCOME_C2_>30' then do; label = "{\b Income \b0 \line \li250   >=$30,000}"; order = 6; ESTIMATE = 99; std = 99; pv = 5; end;
	if variable = 'INCOME_C2_<30' then do; label = "^S={indent=2mm} <$30,000"; order = 6.1; end;
	if variable = 'LANG_PREF_ENGLISH' then do; label = "{\b Language preference \b0 \line \li250   English}"; order = 7; ESTIMATE = 99; std = 99; pv = 5; end;
    if variable = 'LANG_PREF_SPANISH' then do; label = "^S={indent=2mm} Spanish"; order = 7.1; end;
	if variable = 'MARITAL_STATUS_SINGLE' then do; label = "{\b Marital status \b0 \line \li250   Single}"; order = 8; ESTIMATE = 99; std = 99; pv = 5; end;
	if variable = 'MARITAL_STATUS_COHABITING' then do; label = "^S={indent=2mm} Married or Living w/ partner"; order = 8.1; end;
	if variable = 'MARITAL_STATUS_COHABITING/SEPARATED' then do; label = "^S={indent=2mm} Cohabiting, separated, other"; order = 8.1; end;
	if variable = 'MARITAL_STATUS_SEPARATED' then do; label = "^S={indent=2mm} Separated, divorced or widow(er)"; order = 8.2; end;
	if variable = 'PARITY_V1' then do; label = "{\b Parity \b0 \li250}"; order = 9; end;
	if variable = 'POVPCT' then do; label = "{\b Household income as % of poverty \b0 \li250}"; order = 10; end;
	if variable = 'YRSUS_C3_US_BORN' then do; label = "{\b Years in the U.S. \b0 \line \li250   U.S.-born}"; order = 12; ESTIMATE = 99; std = 99; pv = 5; end;
	if variable = 'YRSUS_C3_<10_Years' then do; label = "^S={indent=2mm} <10 years"; order = 12.1; end;
	if variable = 'YRSUS_C3_10+_Years' then do; label = "^S={indent=2mm} >=10 years"; order = 12.2; end;
	if variable = 'YRSUS_C3_L10' then do; label = "^S={indent=2mm} <10 years"; order = 12.1; end;
	if variable = 'YRSUS_C3_G10' then do; label = "^S={indent=2mm} >=10 years"; order = 12.2; end;

	* model 2 variables;
	if variable = 'AGG_MENT' then do; label = "{\b SF-12v2 Health Survey \b0 \line \li250   Mental health summary score}"; order = 0.030; end;
	if variable = 'AGG_PHYS' then do; label = "^S={indent=2mm} Physical health summary score"; order = 0.031; end;
	if variable = 'CESD10' then do; label = "{\b Mental health \b0 \line \li250   Depression score (CESD-10)}"; order = 0.032; end;
	if variable = 'CESD10_NODEPRE' then do; label = "{\b Depression symptoms (CESD-10) \b0 \line \li250   No (<10)}"; order = 0.0321; ESTIMATE = 99; std = 99; pv = 5; end;
	if variable = 'CESD10_DEPRE' then do; label = "^S={indent=2mm} Yes (>=10)"; order = 0.0322; end;
	if variable = 'STAI10' then do; label = "^S={indent=2mm} Anxiety score (STAI-10)"; order = 0.033; end;
	if variable = 'STAI10_NOANX' then do; label = "{\b Anxiety symptoms (STAI-10) \b0 \line \li250   No (<20)}"; order = 0.0331; ESTIMATE = 99; std = 99; pv = 5; end;
	if variable = 'STAI10_ANX' then do; label = "^S={indent=2mm} Yes (>=20)"; order = 0.0332; end;
	if variable = 'HEIGHT' then do; label = "{\b Anthropometry \b0 \line \li250   Height (cm)}"; order = 0.034; end;
	if variable = 'HAZ' then do; label = "{\b Height-for-age z score \b0 \li250}"; order = 0.034; end;
	if variable = 'ANTA10A' then do; label = "^S={indent=2mm} Waist circumference (cm)"; order = 0.035; end;
	if variable = 'BMI' then do; label = "^S={indent=2mm} Body Mass Index (BMI)"; order = 0.036; end;

	* model 3 variables;
	if variable = 'ALCOHOL_USE_NEVER' then do; label = "{\b Alcohol use \b0 \line \li250   Never}"; order = 0.010; estimate = 98; std = 99; pv = 5; end;
	if variable = 'ALCOHOL_USE_FORMER' then do; label = "^S={indent=2mm} Former"; order = 0.011; end;
	if variable = 'ALCOHOL_USE_CURRENT' then do; label = "^S={indent=2mm} Current"; order = 0.012; end;
	if variable = 'CURRENT_SMOKER_NO' then do; label = "{\b Smoking status \b0 \line \li250   Not currently smoking}"; order = 0.013; pv = 5; estimate = 98; std = 99; end;
	if variable = 'CURRENT_SMOKER_YES' then do; label = "^S={indent=2mm} Current smoker"; order = 0.014; end;
	if variable = 'CURRENT_SMOKER' then do; label = "^S={indent=2mm} Current smoker"; order = 0.015; end;
    if variable = 'CIGARETTE_USE_NEVER' then do; label = "{\b Smoking status \b0 \line \li250   Never}"; order = 0.013; pv = 5; estimate = 98; std = 99; end;
	if variable = 'CIGARETTE_USE_FORMER' then do; label = "^S={indent=2mm} Former"; order = 0.014; end;
	if variable = 'CIGARETTE_USE_CURRENT' then do; label = "^S={indent=2mm} Current"; order = 0.015; end;	
	if variable = 'HEI2010' then do; label = "{\b Healthy Eating Index (HEI-2010) \b0}"; order = 0.016; end;
	if variable = 'HEI2010_C3_LOW' then do; label = "{\b Healthy Eating Index (HEI-2010) \b0 \line \li250   Low (<=50.1)}"; order = 0.01601;  estimate = 98; std = 99; pv = 5;  end;
	if variable = 'HEI2010_C3_MEDIUM' then do; label = "^S={indent=2mm} Medium (>50.1-60.5)"; order = 0.01602; end;
	if variable = 'HEI2010_C3_HIGH' then do; label = "^S={indent=2mm} High (>60.5)"; order = 0.01603; end;
	if variable = 'PCT_MVPA' then do; label = "{\b % Time in MVPA \b0}"; order = 0.017; end;
	if variable = 'SLPDUR' then do; label = "{\b Sleeping duration (>8 hrs/day) \b0}"; order = 0.018; end;
	if variable = "PAG2008YN_YES" then do; label = "{\b Meets 2008 PA guidelines \b0 \line \li250   Yes}"; order = 0.019; ESTIMATE = 99; std = 99; pv = 5; end;
	if variable = "PAG2008YN_NO" then do; label = "^S={indent=2mm} No"; order = 0.020; end;
	if variable = 'SLPDUR_LT8HRS_<8_hours' then do; label =  "{\b Sleep duration \b0 \line \li250   Less than 8 hours}"; order = 0.021; ESTIMATE = 99; std = 99; pv = 5; end;
	if variable = 'SLPDUR_LT8HRS_>=8_hours' then do; label = "^S={indent=2mm} More than 8 hours"; order = 0.022; end;

	*model 5 variable; 
	if variable = 'CHILD_PRS_BMI_A' then do; label = "{\b Child's obesity Poligenic Risk Score \b0 \li250}"; order = 0.04; end;

	* adjusted by these variables;
	if variable = 'CENTERNUM_BRONX' then do; label = "{\b Field center \line \b0 \li250   Bronx}"; order = 93; ESTIMATE = 99; std=99; pv = 5; end;
	if variable = 'CENTERNUM_CHICAGO' then do; label = "^S={indent=2mm} Chicago"; order = 93.1; end;
	if variable = 'CENTERNUM_MIAMI' then do; label = "^S={indent=2mm} Miami"; order = 93.2; end;
	if variable = 'CENTERNUM_SAN DIEGO' then do; label = "^S={indent=2mm} Bronx"; order = 93.3; end;
	if variable = 'YRS_BTWN_V1FLOR' then do; label = "{\b Years between baseline & FLOR \b0 \li250}"; order = 95; end;
	if variable = 'YRSV1BIRTH' then do; label = "{\b Years between baseline & birth \b0 \li250}"; order = 95; end;
%MEND LABELS;
