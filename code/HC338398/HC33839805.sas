%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
%let job = HC338398;
%let subjob = HC33839805;
* proc printto log="&homepath.\code\&job.\&subjob._&sysdate..log" 
	print = "&homepath.\code\&job.\&subjob._&sysdate..lst" new; 
run;

/************************************************************
*                                                        
*  PROGRAM NAME: HC33839805.sas
*                                       
*  PROGRAMMER:	Álvaro Quijano (AQ)
*
*  DESCRIPTION: Calculate frequencies to support manuscript's
				supplemental material
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338398
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
*					28aug25: Create the file
*
* ----------------------------------------------------------
*
*  INPUT: 
*                                        
*  OUTPUT: 
*
**********************************************************/
options orientation = portrait nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 
ods escapechar '^';

* Set libraries name; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';
libname hc3383 'J:\HCHS\SC\Review\HC3383';
libname invv1 'J:\HCHS\SC\Sasdata\INV_Use\Consolidated';
libname invv2 'J:\HCHS\SC\Sasdata\Visit2\INV_Use\Consolidated';
libname flor 'J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\INV_Use\Datasets';
libname floriu 'J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\Internal_Use';

* Set macro variables; 
%let prg = AQA;
%let comp_all = hc3383.hc338301_all;

* Set footnote;
footnote j=left height=10pt font='ARIAL' "Job &job run by &PRG on %sysfunc(today(), date9.) at %sysfunc(time(), timeampm.)";

* Define formats;
proc format;
	value sex_fmt
	0 = 'Women'
	1 = 'Men'
	;
	value age_fmt
	18-44 = '18-44'
	45-HIGH = '45+'
	;
	value yn_fmt
	0 = 'No'
	1 = 'Yes'
	;
	value baby1yn_fmt
	. = 'Twins'
	1 = 'Singleton between V1 and V2'
	;
	value eleb4_fmt
	2 = 'Unable to contact'
	1 = 'Refuse'
	3 = 'Ineligible'
	;
run;

ods rtf file = "&homepath./code/&job./&subjob._Supplemental_frequencies.rtf";
title height=13pt font='times' bold 'Participants at Visit 1 (V1)';
title2 height=8pt font='times' 'Participants in PART_DERV_INV5';
proc sql;
	select count(distinct id) as n label = 'Frequency'
	from invv1.part_derv_inv5;
quit; 

title height=13pt font='times' bold 'Women/Men at Visit 1 (V1)';
title2 height=8pt font='times' 'Participants in PART_DERV_INV5 by sex';
proc sql;
select sex as sex format sex_fmt., count(distinct id) as n label = 'Frequency'
	from invv1.part_derv_inv5
	group by sex;
quit;

title height=13pt font='times' bold 'Women by age at Visit 1 (V1)';
title2 height=8pt font='times' 'Women in PART_DERV_INV5 by age group';
proc sql;
	select put(age, age_fmt.) as AgeGroup, count(distinct id) as n label = 'Frequency'
	from invv1.part_derv_inv5
	where sex = 0
	group by AgeGroup
	;
quit;

title height=13pt font='times' bold 'Women 18-44y at Visit 2 (V2)';
title2 height=8pt font='times' "Women (V1, SEX=0) aged 18-44 at visit 1";
* Merge V1 and V2;
*  keep women aged 18 to 44 at V1;
*  flag those in V1 but not at V2;
data id_wm_age;
	merge invv1.part_derv_inv5(keep=id age sex in=in_a) invv2.part_derv_v2_inv3(keep=id gender_v2 in=in_b);
	by id;
	if in_b = 1 and in_a = 1 then in_visit_2 = 1; 
	else if  in_b = 0 then in_visit_2 = 0;

	if (age >= 18 and age <= 44) and in_a; 
run;
proc sql;
	select in_visit_2 label = 'In visit 2' format yn_fmt., count(id) as n label = 'Women aged 18 to 44 at V1'
	from id_wm_age
	where sex=0
	group by in_visit_2;
quit;
title2 height=8pt font='times' "Discrepancies between sex and gender_v2 variables at V1 and V2";
proc freq data = id_wm_age; 
	ods noproctitle;
	table gender_v2 * sex  / missing norow nocol nopercent;
run;

* Singleton between V1 and V2;
title height=13pt font='times' bold 'Singleton between V1 & V2';
title2 height=8pt font='times' 'Single livebirth (PCE3 and PCE3a=1) reported within the same pregnancy';
proc sql;
	select count(distinct id) as n
	from invv2.pce_v2_inv3
	where pce3 = 1 and PCE3a = 1;
quit;

* pair of twins;
title height=13pt font='times' bold 'Pairs of twins';
title2 height=8pt font='times' 'Two livebirths (PCE3 and PCE3a=2) reported within the same pregnancy';
proc sql;
	select count(distinct id) as n
	from invv2.pce_v2_inv3
	where pce3 = 1 and pce3a = 2;
quit;

* singleton with no v2;
title height=13pt font='times' bold 'Singleton not at V2 but in FLOR';
title2 height=8pt font='times' 'MOM_ID in FLOR (not in V2)';
proc sql;
	select count(distinct id) as n
	from flor.flor_part_derv_inv2
	where id not in (
		select id from invv2.part_derv_v2_inv3
	);
quit;

* singleton after V2;
title height=13pt font='times' bold 'Singleton after V2';
title2 height=8pt font='times' 'IDs with BORN_AFTERV2 = 1';
proc sql;
	select count(distinct id) as n
	from flor.flor_part_derv_inv2
	where born_afterv2 = 1;
quit;

title height=13pt font='times' bold 'Screened for SOL FLOR';
title2 height=8pt font='times' 'Subjects had a partipation status';
proc sql;
	select count(distinct subjectid) as n label = 'Frequency'
	from floriu.eleb_iu2
	where eleb4 > 0;
quit;

title height=13pt font='times' bold 'Screened for SOL FLOR [Unable]';
title2 height=8pt font='times' 'ELEB4 = 1';
proc sql;
	select count(distinct subjectid) as n label = 'Frequency'
	from floriu.eleb_iu2
	where eleb4 = 1;
quit;

title height=13pt font='times' bold 'Screened for SOL FLOR [Unable, Refused, Ineligible]';
title2 height=8pt font='times' 'ELEB4 = 1, 2 or 3';
proc freq data = floriu.eleb_iu2;
	table eleb4; 
	where eleb4 in (1,2,3);
	format eleb4 eleb4_fmt.;
run;

title height=13pt font='times' bold 'Eligible to participate in SOL FLOR';
title2 height=8pt font='times' 'Participants with ELEB4 (ELEB_IU2) in (4,5)';
proc sql;
	select count(distinct subjectid) as n label = 'Frequency'
	from floriu.eleb_iu2
	where eleb4 in (4,5);
quit;

title height=13pt font='times' bold 'Eligible but refuse to participate in SOL FLOR';
title2 height=8pt font='times' 'Participants with ELEB4 (ELEB_IU2) equal to 4';
proc sql;
	select count(distinct subjectid) as n label = 'Frequency'
	from floriu.eleb_iu2
	where eleb4=4;
quit;

/*
proc freq data = floriu.eleb_iu2;
	table eleb4 / missing list norow nocol nopercent;
run;
*/

title height=13pt font='times' bold 'Participate in SOL FLOR';
title2 height=8pt font='times' 'Participants in FLOR_PART_DERV';
proc sql;
	select count(distinct id) as n label = 'Frequency'
	from flor.flor_part_derv_inv2;
quit;


title height=13pt font='times' bold 'Phone questionnaires only';
title2 height=8pt font='times' 'PROTOCOL_TYPE (FLOR_PART_DERV) equal to 2 (Phone only)';
proc sql;
	select count(distinct id) as n label = 'Frequency'
	from flor.flor_part_derv_inv2 
	where protocol_type = 2;
quit;

title height=13pt font='times' bold 'Child Antropometry in SOL FLOR';
title2 height=8pt font='times' 'PROTOCOL_TYPE (FLOR_PART_DERV) not equal to 2 (Phone only)';
proc sql;
	select count(distinct id) as n label = 'Frequency'
	from flor.flor_part_derv_inv2 
	where protocol_type ^= 2;
quit;


title height=13pt font='times' bold 'Pre-COVID-19 (9/19-2/20) Clinic Measurements';
title2 height=8pt font='times' 'Children with PROTOCOL_TYPE (FLOR_PART_DERV) equal to 1 (Pre-COVID)';
proc sql;
	select count(distinct id) as n label = 'Frequency'
	from flor.flor_part_derv_inv2 
	where protocol_type = 1;
quit;

title height=13pt font='times' bold 'COVID-19 (3/20-9/22) Clinic Measurements';
title2 height=8pt font='times' 'Children with PROTOCOL_TYPE (FLOR_PART_DERV) equal to 3 (Phone/clinic anthropometry)';
proc sql;
	select count(distinct id) as n label = 'Frequency'
	from flor.flor_part_derv_inv2 
	where protocol_type = 3;
quit;

title height=13pt font='times' bold 'COVID-19 (3/20-9/22) Home Measurements';
title2 height=8pt font='times' 'Children with PROTOCOL_TYPE (FLOR_PART_DERV) equal to 4 (Phone/remote anthropometry)';
proc sql;
	select count(distinct id) as n label = 'Frequency'
	from flor.flor_part_derv_inv2 
	where protocol_type = 4;
quit;

ods rtf close;
proc printto; run;
