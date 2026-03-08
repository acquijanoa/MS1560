%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
proc printto log="&homepath.\code\HC338355\HC338355_&sysdate..log" 
	print = "&homepath.\code\HC338355\HC338355_&sysdate..lst" new; 
run;

/*********************************************************
*                                                         *
*  SAS PROGRAM - QC DATASET JOB HC3383 					         *
*                                                        *
**********************************************************
*                                                        *
*  PROGRAM NAME: HC338355.sas
*                                       
*  PROGRAMMER: Álvaro Quijano (AQ)
*
*  DESCRIPTION: Imputation model				
*
* ---------------------------------------------------------
*
*  JOB NUMBER: HC338355
*
*  PREVIOUS JOB: 
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL: 
					03jun25: create the file

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

* Set macro variables; 
%let job = HC338355;
%let prg = AQA;
%let impdb = data.hc338353_imputed_data_20aug25;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;

* Include sas scripts with formats and macros;
%include "&homepath.\code\HC338390\HC338390.sas"; * Formats ;

* var_labels dataset ;
data var_labels;
    length source $32 label $200;
    infile datalines dsd truncover;
    input source :$32. classval0 label :$200. order;
    datalines;
/* --- BKGRD1_C7NOMISS --- */
BKGRD1_C7NOMISS,3,"{\b Hispanic/Latino Background \b0 \line \li250   Mexican}",2
BKGRD1_C7NOMISS,4,"^S={indent=2mm} Puerto Rican",2.1
BKGRD1_C7NOMISS,2,"^S={indent=2mm} Cuban",2.2
BKGRD1_C7NOMISS,0,"^S={indent=2mm} Dominican",2.3
BKGRD1_C7NOMISS,1,"^S={indent=2mm} Central American",2.4
BKGRD1_C7NOMISS,5,"^S={indent=2mm} More than one heritage",2.5
BKGRD1_C7NOMISS,6,"^S={indent=2mm} Other heritage",2.6
/* --- N_HC --- */
N_HC,1,"{\b Health Insurance \line \b0 \li250   Yes}",3
N_HC,0,"^S={indent=2mm} No",3.1
/* --- EDUCATION_C3 --- */
EDUCATION_C3,1,"{\b Education \b0 \line \li250   Not High school or GED}",4
EDUCATION_C3,2,"^S={indent=2mm} At most High school or GED",4.1
EDUCATION_C3,3,"^S={indent=2mm} Greater than high school graduate",4.2
/* --- EMPLOYEDYN --- */
EMPLOYEDYN,0,"{\b Employment status \b0 \line \li250   Not employed}",5
EMPLOYEDYN,1,"^S={indent=2mm} Employed",5.1
/* --- INCOME_C2 --- */
INCOME_C2,2,"{\b Income \b0 \line \li250   >=$30,000}",6
INCOME_C2,1,"^S={indent=2mm} <$30,000",6.1
/* --- LANG_PREF --- */
LANG_PREF,2,"{\b Language preference \b0 \line \li250   English}",7
LANG_PREF,1,"^S={indent=2mm} Spanish",7.1
/* --- MARITAL_STATUS --- */
MARITAL_STATUS,1,"{\b Marital status \b0 \line \li250   Single}",8
MARITAL_STATUS,2,"^S={indent=2mm} Married or Living w/ partner",8.1
MARITAL_STATUS,3,"^S={indent=2mm} Separated, divorced or widow(er)",8.2
/* --- CENTERNUM --- */
CENTERNUM,1,"{\b Field center \line \b0 \li250   Bronx}",93
CENTERNUM,2,"^S={indent=2mm} Chicago",93.1
CENTERNUM,3,"^S={indent=2mm} Miami",93.2
CENTERNUM,4,"^S={indent=2mm} San Diego",93.3
/* --- YRSUS_C3 --- */
YRSUS_C3,3,"{\b Years in the U.S. \b0 \line \li250   U.S.-born}",12
YRSUS_C3,1,"^S={indent=2mm} <10 years",12.1
YRSUS_C3,2,"^S={indent=2mm} >=10 years",12.2
/* --- ALCOHOL_USE --- */
ALCOHOL_USE,1,"{\b Alcohol use \b0 \line \li250   Never}",26
ALCOHOL_USE,2,"^S={indent=2mm} Former",26.1
ALCOHOL_USE,3,"^S={indent=2mm} Current",26.2
/* --- CURRENT_SMOKER --- */
CURRENT_SMOKER,.,"^S={indent=2mm} Current smoker",27.1
/* --- Continuous variables --- */
AGE,., "{\b Maternal age \b0 \li250}",1
YRSV1BIRTH,., "{\b Years between baseline & birth \b0 \li250}",95
POVPCT,., "{\b Household income as % of poverty \b0 \li250}",10
BMI,., "^S={indent=2mm} Body Mass Index (BMI)",23.2
ANTA10A,., "^S={indent=2mm} Waist circumference (cm)",23.1
HEIGHT,., "{\b Anthropometry \b0 \line \li250   Height (cm)}",23
CHILD_PRS_BMI_A,., "{\b Child Polygenic Risk Score \b0 \li250}",40
AGG_MENT,., "{\b SF-12v2 Health Survey \b0 \line \li250   Mental health summary score}",20
AGG_PHYS,., "^S={indent=2mm} Physical health summary score",20.1
CESD10,., "{\b Mental health \b0 \line \li250   Depression score (CESD-10)}",20.5
STAI10,., "^S={indent=2mm} Anxiety score (STAI-10)",20.6
HEI2010,., "{\b Healthy Eating Index (HEI-2010) \b0}",28
PCT_MVPA,., "{\b % Time in MVPA \b0}",29
SLPDUR,., "{\b Sleeping duration \b0}",30
PARITY_V1,., "{\b Number of live births \b0 \li250}",9
;
run;

/*----------------------------------------------------------
 Macro: run_univariate
 Purpose: Run univariate models for both categorical and
          continuous predictors, merge results.
-----------------------------------------------------------*/

%macro run_univariate(data=, outcome=, catvars=, contvars=);

* %let data =  &impdb.;
* %let var = age;
* %let outcome = birthwt_ga_z; 

   * --- categorical variables --- ;
   %let i=1;
   %let var0=%scan(&catvars, &i,' '); %put &var0.; 
	   %let var = %scan(&var0,1,'-'); %put &var.;
	   %let ref = %scan(&var0,2,'-'); %put &ref.;
 
   %do %while(&var ne);
	* Generates the model;
    proc mixed data = &data.; 
		by _imputation_;
		class &var.(ref="&ref.");
		model &outcome. = &var. / solution;
		ods output solutionF=estimates;
	run;

	* Combine imputed values;
	proc mianalyze parms(classvar=full)=estimates;
		modeleffects &var.;
		class &var.;
		ods output ParameterEstimates=est;
	run;

	* edit dataset to match final output;
	data &var._out;
		set est;
		keep source probt &var.;
		
		* create the new variable;
		Source = upcase(Parm);
		rename &var. = ClassVal0;
		rename probt = Prob;
	run;
		
	* update counter ;
      %let i=%eval(&i+1); %put &i.;
      %let var0=%scan(&catvars, &i, ' '); 
	    %let var = %scan(&var0,1,'-'); 
	    %let ref = %scan(&var0,2,'-'); 
   %end;

   * --- continuous variables --- ;
   %let j=1;
   %let var=%scan(&contvars, &j);

   %do %while(&var ne);

   proc glm data=&data;
	  by _imputation_;
      ods select ParameterEstimates;
	  ods output ParameterEstimates = pars_est;
      model &outcome = &var / solution;
   run; quit;

   proc mianalyze parms= pars_est;
		modeleffects &var.;
		ods output ParameterEstimates = &var._pooled;
   run;

   data &var._out;
     set &var._pooled;
     keep Source ClassVal0 ProbT;

	 ClassVal0 = .;
	 rename ProbT= Prob;
     Source = upcase(Parm);
   run;

      * update counter ;
	  %let j=%eval(&j+1);
      %let var=%scan(&contvars, &j);
   %end;

   /* --- Merge all outputs --- */
   data all_univariate_results;
      set
      %let i=1;
      %let var0=%scan(&catvars, &i,' ');
	  %let var = %scan(&var0,1,'-'); 
      %do %while(&var ne);
         &var._out       
		 %let i=%eval(&i+1);
         %let var0=%scan(&catvars, &i, ' ');
	     %let var = %scan(&var0,1,'-'); 
      %end;

      %let j=1;
      %let var=%scan(&contvars, &j);
      %do %while(&var ne);
         &var._out
         %let j=%eval(&j+1);
         %let var=%scan(&contvars, &j);
      %end;
      ;
   run;

   * Sort dataset;
   proc sort data = all_univariate_results; by source classval0; run;
   proc sort data = var_labels; by source classval0; run;

   * Insert Label by Variable;
   data all_univariate;
    merge all_univariate_results (in=a) var_labels (in=b);
    by Source classval0;

	if missing(prob) then prob = 97;

    if a;
    if not b then label=Source; 
    run;	

	proc sort data=all_univariate; by order; run;

	* end macro;
%mend run_univariate;

* Define categorical variables; 
%let catvars = centernum-1 income_c2-2 lang_pref-2 bkgrd1_c7nomiss-3 
               marital_status-1 employedyn-0 education_c3-1 n_hc-1 yrsus_c3-3 
               alcohol_use-1;

* Define continuous variables; 
%let contvars = yrsv1birth age povpct bmi anta10a height child_prs_bmi_a current_smoker
                agg_ment agg_phys cesd10 stai10 hei2010 pct_mvpa slpdur parity_v1;

* Executes macro;
%run_univariate(data=&impdb, outcome=birthwt_ga_z, 
                catvars=&catvars, contvars=&contvars);

* Calculate correlations;
proc corr data = &impdb. out=corrs;  
	by _imputation_;
	var &contvars. lang_pref income_c2 marital_status employedyn n_hc alcohol_use education_c3 yrsus_c3 accult_mesa;
run;

* Update corrs dataset;
data corrs;
	set corrs;
	drop _TYPE_;

	rename _NAME_ = variable;
	if ^missing(_NAME_);
run;

* Edit the data;
data long; set corrs end=eof;
  keep _imputation_ variable vname corr ;
  array c (*) &contvars.  lang_pref income_c2 marital_status employedyn n_hc alcohol_use education_c3 yrsus_c3 accult_mesa;
  do i=1 to dim(c);
     vname=vname(c(i));
     corr=c(i);
     output;
  end;
  if eof then do;
    variable=''; vname=''; corr=1; output;
    variable=''; vname=''; corr=1; output;
  end;
run;

* ;
data long;
	set long;
	* convert to positive the correlation values for ordering;
	corr_pos = abs(corr);

	* exclude -1 or;
	if corr ^= 1;
run;

* Sort by imputation;
proc sort data = long; by _imputation_ descending corr_pos; run;

* Produce rank;
proc rank data = long out = ranked ties=low descending; 
	by _imputation_;
	var corr_pos;
	ranks corr_rank;
run;

* Select the first 10;
proc sql;
	create table corr_per_simulation as
	select *
	from ranked 
	where corr_rank <= 30 and variable < vname
	order by _imputation_, corr_pos desc
	;
quit;

ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file="&homepath./code/&job./&job._Univariate_analysis_&sysdate..rtf" style=manuscrt bodytitle;
proc report data = all_univariate;
	title j=center height=11pt font='times roman' bold 'Univariate linear models for the Effect of Maternal Factors on Birthweight-for-Gestational-Age Z-score';
	footnote1 J=LEFT HEIGHT=11pt FONT='times roman' "^S={leftmargin=1.5in rightmargin=1.5in} P-values are based on univariate analysis of linear models pooled across 10 imputations. Each model was fit separately with birthweight-for-gestational-age z-score as the outcome. Reported p-values correspond to the main effect of the variable or level.";
	footnote2 J=LEFT HEIGHT=10pt FONT='times roman' "{\line \line Job &job run by &PRG using FLOR data on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))}";
	column Order Label Prob;
	define order / noprint order=internal;
	define Label / 'Variable';
	define Prob / display 'P-value' style=[vjust=bottom]; 
run;

* Print the report of correlations;
proc report data = corr_per_simulation;
	title j=center height=11pt font='times roman' bold 'Correlation among predictors';
	footnote1 J=LEFT HEIGHT=11pt FONT='';
	by _imputation_;
	column  variable vname corr corr_pos;
	define corr_pos / order=internal noprint;
	define variable / display 'Variable 1';
	define vname / display 'Variable 2';
	define corr / display 'Correlation';
run;

ods rtf close;

