%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\code\HC338352\HC338352_&sysdate..log" 
	print = "&homepath.\code\HC338352\HC338352_&sysdate..lst" new; 
run;

/*********************************************************
*                                                         *
*  SAS PROGRAM - QC DATASET JOB HC3383 					         *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338352.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: Imputation model
				
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338352   
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
					22apr25: (HC338351) Creates the file
					23apr25: update input dataset to 0423
					12may25: updated to use the SC dataset from HC3383
					13may25: income_c2 included in the 1st output table 
					23jun25: update input dataset (*_23jun25)
								include slpdur variable in missing pattern table
					19aug25: update input dataset to *_19aug25
					02sep25: update response to be birthwt_ga_z and not WAZ
					04nov25: update input dataset to *_04nov25
							 add slpdur_lt8hrs and pag2008yn to table
							 drop slpdur and pct_mvpar from table
							 drop anthropometrics (bmi, anta10a and height) from analysis
							 drop income_c2, povpct, agg_ment and agg_phys from table
							 response is set back to WAZ
							 update hei2010 to hei2010_c3
				
* ----------------------------------------------------------
*
*  INPUT: hc338351_flor_23jun25
*
*  OUTPUT: &job._missing_pattern_&sysdate..rtf file
*
**********************************************************/
options orientation = landscape nodate formchar = "|----|+|---+=|-/\<>*" nonumber PS=59 LS=173; 
ods escapechar '^';

* Set libraries name; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';
libname hc3383 'J:\HCHS\SC\Review\HC3383'; 

* Set macro variables; 
%let job = HC338352;
%let prg = AQA;
%let data = data.hc338351_flor_04nov25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath\code\&job.\&job._misspattern_&sysdate..rtf" bodytitle style=manuscrt;
ods noproctitle;
* Maternal socio-demographic and acu;
 title1 J=center height=12pt bold font='TIMES ROMAN' "MS#1560 SOL/FLOR preconceptional factors and child weight" ;
         title3 J=center height=11pt bold font='TIMES ROMAN' 'Confidential/Not for distribution';
         title5 J=center height=12pt bold font='TIMES ROMAN' "^S={leftmargin=&lf_margin rightmargin=&rg_margin} Table 0.  Missing patterns of sociodemographic and acculturation factors and child weight among Hispanic/Latina mother-child dyads in the HCHS/SOL Study";
         footnote1 J=left height=10pt font='TIMES ROMAN' "^S={leftmargin=&lf_margin rightmargin=&rg_margin} Variables BKGRD1_C7, AGE and LANG_PREF are not included since have no missing data";
		 footnote2 J=left height=10pt font='TIMES ROMAN' "^S={leftmargin=&lf_margin rightmargin=&rg_margin} Abbrev: weight-for-age z-score (WAZ), health coverage (N_HC), years in the US (YRSUS).";
		 footnote3 J=center height=10pt font='TIMES ROMAN' "&sysdate, &systime -- &job (&prg) using V1 and FLOR inv_use data";
	proc mi data = &data nimpute = 0 displaypattern=nomeans;
		ods noproctitle;
		ods select MissPattern;
		var waz parity_v1 marital_status employedyn education_c3 yrsus_c3 n_hc;
	run;

* Physical and mental health, anthropometry;
 title1 J=center height=12pt bold font='TIMES ROMAN' "MS#1560 SOL/FLOR preconceptional factors and child weight" ;
         title3 J=center height=11pt bold font='TIMES ROMAN' 'Confidential/Not for distribution';
         title5 J=center height=12pt bold font='TIMES ROMAN' "^S={leftmargin=&lf_margin rightmargin=&rg_margin} Table 0.  Missing patterns of anthropometry and physical and mental health factors and child weight among Hispanic/Latina mother-child dyads in the HCHS/SOL Study";
         footnote1 J=left height=10pt font='TIMES ROMAN' "^S={leftmargin=&lf_margin rightmargin=&rg_margin} The variable STAI10 was not updated for participants born after Visit 2, since it was not measured at that visit.";
		 footnote2 J=left height=10pt font='TIMES ROMAN' "^S={leftmargin=&lf_margin rightmargin=&rg_margin} Abbrev: weight-for-age z-score (WAZ), 10-items state-trait anxiety inventory (STAI10), Center for Epidemiologic Studies Depression Scale (CESD-10)";
		 footnote3 J=center height=10pt font='TIMES ROMAN' "&sysdate, &systime -- &job (&prg) using V1 and FLOR inv_use data";
	proc mi data = &data nimpute = 0 displaypattern=nomeans;
		ods noproctitle;
		ods select MissPattern;
		var waz cesd10 stai10;
	run;

* Maternal Health behaviors;
 title1 J=center height=12pt bold font='TIMES ROMAN' "MS#1560 SOL/FLOR preconceptional factors and child weight" ;
         title3 J=center height=11pt bold font='TIMES ROMAN' 'Confidential/Not for distribution';
         title5 J=center height=12pt bold font='TIMES ROMAN' "^S={leftmargin=&lf_margin rightmargin=&rg_margin} Table 0.  Missing patterns of maternal health behaviors factors and child weight among Hispanic/Latina mother-child dyads in the HCHS/SOL Study";
         footnote1 J=left height=10pt font='TIMES ROMAN' "^S={leftmargin=&lf_margin rightmargin=&rg_margin} Abbrev: weight-for-age z-score (WAZ), health eating index 2010 (HEI2010), sleep duration (SLPDUR) and Physical actitivity meets 2008 guidelines (PAG2008).";
		 footnote2 J=center height=10pt font='TIMES ROMAN' "&sysdate, &systime -- &job (&prg) using V1 and FLOR inv_use data";
	proc mi data = &data nimpute = 0 displaypattern=nomeans;
		ods noproctitle;
		ods select MissPattern;
		var waz current_smoker hei2010_c3 alcohol_use pag2008yn slpdur_lt8hrs;
	run;

ods rtf close;
proc printto; run;
