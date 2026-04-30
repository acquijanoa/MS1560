%let homepath=J:\HCHS\STATISTICS\GRAS\QAngarita\FLOR\MS1560;
%LET req=HC3383;
%LET job=&req.02;
proc printto log="&homepath.\scripts\&job.\&job._&sysdate..log" print=
    "&homepath.\scripts\&job.\&job._&sysdate..lst" new;
run;
******************************************************************
  REQUEST:       HC3383

  TITLE:         MS#1560 aAssociation of preconception socio-behavioral factors and child�s weight� by Siega-Riz

  DESCRIPTION:   -  Create an analytic data file for MS #1560 � �Association of preconception socio-behavioral factors 
                   and child�s weight in the HCHS/SOL study� [Grant�s aim #2]
                 -  The statistical analyses and tables will be done by GRA Alvaro under Daniela�s supervision.

  MANUSCRIPT:    HCM1560

  PROGRAMMER:    Dan Piston
                 edited by: Alvaro Quijano (AQA)  

  REQUESTOR:     Daniela Sotres/Alvaro Quijano

  DATE:          4/23/2025
-----------------------------------------------------------------
  JOB NUMBER:    HC338302

  DESCRIPTION:   Create Table 1. Maternal Preconception and Child Characteristics among HCHS/SOL women with a 
                 child born between baseline (2008-11) and Visit 2 (2014-17), by FLOR participation.
            
  LANGUAGE:      SAS VERSION 9.4

  HISTORY:       HC338301 6/23/25 - uccdjp Cont #2 - 
                        Create Table 1 (Section D) using HC338301_ALL data
                        The mean/% and standard deviation (SD) do not account for the HCHS/SOL study design.
                    	The table indicates which variables to use (in red).
                    	Include the categories from the data dictionary for the categorical variables.
                    	Use job HC3131903 as starting point but using the variables relavant to this manuscript
					
				29apr26 
						update label to 'Health Insurance' instead of 'Healthcare access'.
						include child bmi (groups) and cigarette_use in Table 1
						exclude current_smoker 

  NOTE:          Related: HC3139 - MS1207 [FLOR grant aim #1] Uses final INV1 data and MI
-----------------------------------------------------------------
  INPUT:         HC338301_ALL data
                
  OUTPUT:        J:\HCHS\SC\&prog\&req\HC338301_TN1
 
*------------------------------------------------------------------
*******************************************************************;
OPTIONS ps=59 ls=max nodate nonumber MPRINT errors=50 orientation=landscape;
%LET prog=AQA;

FOOTNOTE "Job &job run by &prog on &SYSDATE at &SYSTIME";

%let home=J:\HCHS\SC\&prog.\&req.;
%put JOB=&job.;
libname mylib "&homepath.\data";
libname flor 'J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\INV_Use\Datasets';

* %let workspace = J:\HCHS\SC\&prog.\&req.;
data all;
    set mylib.hc338351_all_12nov25;
run;

data child;
    set flor.DEMB_INV2 (keep=ID DEMB1); /* DEMB1 = CHILD_SEX */
run;

data repdata;
    merge all (in=want) child;
    by id;
    if want;
run;

DATA _NULL_ ;
    CALL SYMPUT('x',LEFT(INPUT("A0",$hex2.))) ;
RUN;
%LET y=&x&x&x;

PROC FREQ data=repdata;
    table EDUCATION_C3*FLOR_DYAD / chisq;
    *ods output ChiSq = chisq_out (where = (Statistic="Chi-Square") rename=(prob=p));
run;

proc freq data=repdata;
    table DEMB1*FLOR_DYAD / list missing;
run;

data toplines;
    length vartext $100;

    line=0;
    vartext='Sociodemographic';
    output;

    line=1;
    vartext='Hispanic/Latina background, %';
    output;

    line=2;
    vartext='Education, %';
    output;

    line=3;
    vartext='Income, % ';
    output;

    line=4;
    vartext='Marital status, %';
    output;

    line=5;
    vartext='Employment, %';
    output;

    line=6;
    vartext='Years in the US, %';
    output;

    line=7;
    vartext='Health insurance';
    output;

    line=8;
    vartext='Acculturation' ;
    output;

    line=9;
    vartext='Language of Preference, %';
    output;

    line=10;
    vartext='Physical and Mental Health';
    output;

    line=11;
    vartext='Anthropometry';
    output;

    line=12;
    vartext='Health Behaviors';
    output;

    line=13;
    vartext='Alcohol Use, %';
    output;

    line=14;
    vartext='Smoking, %';
    output;

    line=15;
    vartext='Meets 2008 PA guidelines, %';
    output;

    line=16;
    vartext='Child characteristics';
    output;

    line=17;
    vartext='Sex, %';
    output;

	line=18;
    vartext='BMI';
    output;
run;

******************** CATEGORICAL MACROS *****************;

* create a single row for a level of a categorical var;
%macro categorical(var, varlevel, text, denomlogic, modelpos);

    * testing;
    /*
    %categorical(DEMB1,1,&y Boy, DEMB1 gt .z, 1);
    %let var= DEMB1;
    %let varlevel= 1;
    %let text = %str(&y Boy);
    %let denomlogic=not missing(DEMB1);
    %let modelpos= 1;
     */
    %model_cat(&var);

    * use count and pct_row measures from proc freq for calculations;
    proc freq data=derive2(where=(&denomlogic)) noprint;
        tables flor_dyad*&var / missing outpct out=myout(keep=flor_dyad &var
            count pct_row where=(&var=&varlevel));
    run;

    /*format the stats as needed*/
    data cp;
        set myout;
        length cp_n cp_pct $20;
        cp_n=strip(put(count,8.));
        cp_pct=strip(put(pct_row,5.1)) || '%';
    run;

    /* transpose twice, note use of "suffix" to distinguish */
    proc transpose data=cp prefix=flor_dyad suffix=_n out=&var.n (drop=_name_);
        by &var;
        id flor_dyad;
        var cp_n;
    run;

    proc transpose data=cp prefix=flor_dyad suffix=_p out=&var.pct
        (drop=_name_);
        by &var;
        id flor_dyad;
        var cp_pct;
    run;

    /*combine and add final touches*/
    data &var._&varlevel;
        length vartext $200 var $50;
        merge &var.n &var.pct;
        by &var;
        vartext="&text";
        var="&var";

        if upcase(&var)="DEMB1" then do;
            flor_dyad0_n='0';
            flor_dyad0_p='**';
        end;

        rename flor_dyad0_n=nonflor_n flor_dyad0_p=nonflor_p flor_dyad1_n=flor_n
            flor_dyad1_p=flor_p ;
    run;

    %if &varlevel=&modelpos %then %do;

        data &var._&modelpos;
            merge &var._&modelpos chisq_&var ;
            by var;
        run;

    %end;

    run;

%mend;

/*
%let catvar=DEMB1;
 */
%macro model_cat(catvar);

    %if %upcase(&catvar)=DEMB1 %then %do;
        %put DEMB1;
        %let pcat=**;
    %end;
    %else %do;
        PROC FREQ data=repdata;
            table &catvar*FLOR_DYAD / chisq;
            ods output ChiSq=chisq_out (where=(Statistic="Chi-Square")
                rename=(prob=p));
        run;

        proc sql;
            select strip(put(p,pvalue6.3)) into :pcat trimmed from chisq_out;
        quit;
    %end;
    %put pcat &pcat;

    data chisq_&catvar;
        length var $50 pvalue $15;
        set chisq_out;
        var="&catvar";
        pvalue=strip("&pcat");
        keep var pvalue;
    run;

%mend;

************************* CONTINUOUS MACROS *******************;
%macro continuous(var, text, logic);

    /*
     * testing;
     *%let var=YRS_BTWN_V1V2;
    %let var=YRS_BTWN_V1FLOR;
    %let text=abc;
     *%let logic =YRS_BTWN_V1V2 gt .z;
    %let logic = YRS_BTWN_V1FLOR gt .z;
     */
    /*
    proc sql;
    select sum(flor_dyad=0) into :ct_flor_dyad_0 from repdata
    where YRS_BTWN_V1FLOR gt .z
    ;
     */
    %model_cont(&var)

    proc means data=repdata (where=(&logic)) noprint;
        class flor_dyad;
        var &var;
        output out=meansout /autoname;
    run;

    data suffix;
        length statistic $20;
        set meansout;
        if flor_dyad=0 then do;
            if _stat_='N' then statistic='n_nonflor';
            if _stat_='STD' then statistic='std_nonflor';
            if _stat_='MEAN' then statistic='mean_nonflor';
        end;
        if flor_dyad=1 then do;
            if _stat_='N' then statistic='n_flor';
            if _stat_='STD' then statistic='std_flor';
            if _stat_='MEAN' then statistic='mean_flor';
        end;
        if not missing(statistic);
        if char(statistic,1)='n' then value=put(&var,8.);
        else if char(statistic,1)='m' then value=put(&var,6.1);
        else value=put(&var,5.1);
        keep value statistic;
    run;

    proc print;

    proc contents;
    run;

    proc transpose data=suffix out=t(drop=_name_ );
        id statistic;
        var value;
    run;

    proc print;
    run;

    %if &var=YRS_BTWN_V1FLOR %then %do;
        data &var;
            length vartext $200 pvalue $15 ;
            length nonflor_n nonflor_p flor_n flor_p $50;

            vartext="&text";
            overall_n='291';
            v2_n='**';
            flor_n='291';
            overall_p='10.9 (1.2)';
            v2_p='**';
            flor_p='10.9 (1.2)';
            pvalue='**';
        run;
    %end;

    %else %do;
        data &var;
            length vartext $200 pvalue $15 ;
            length nonflor_p flor_p $50;
            set t;

            %if %upcase(&var)=WAZ %then %do;
                n_nonflor='';
                nonflor_p='';
                pvalue='**';
            %end;
            %else %do;
                nonflor_p=strip(mean_nonflor) || ' (' || strip(std_nonflor) ||
                    ')';
                pvalue=strip("&pcont");
            %end;

            flor_p=strip(mean_flor) || ' (' || strip(std_flor) || ')';
            vartext="&text";

            keep vartext pvalue nonflor_p flor_p n_nonflor n_flor ;

            rename n_nonflor=nonflor_n n_flor=flor_n ;
        run;

    %end;

%mend;

%macro model_cont(contvar);
    %global pcont;

    PROC GLM data=repdata;
        class FLOR_DYAD;
        model &contvar=FLOR_DYAD;
        ods output ModelANOVA=anovaout(where=(HypothesisType=1) ) ;
    quit;

    proc print;
    run;

    proc sql;
        select strip(put(probf,pvalue6.3)) into :pcont trimmed from anovaout;
    quit;
    %put pcont &pcont;

    run;

%mend;

******;
data derive2;
    set repdata;
    output;
    flor_dyad=9;
    output;
run;

proc freq;
    table flor_dyad;
run;

* for header N's;
proc freq data=derive2;
    tables flor_dyad/out=flor_dyad_counts(keep=flor_dyad count);

proc print data=flor_dyad_counts;
run;
/*proc contents data=derive2; run;*/

* store flor_dyad counts for use later in header;
data _null_;
    set flor_dyad_counts;
    if flor_dyad=0 then call symput('nonflor_ct',strip(put(count,8.)));
    if flor_dyad=1 then call symput('flor_ct',strip(put(count,8.)));
    if flor_dyad=9 then call symput('overall_ct',strip(put(count,8.)));
run;

%continuous(age,%bquote(Age (yrs)),age gt .z) 
%categorical(BKGRD1_C7NOMISS,2,&y Cuban,BKGRD1_C7NOMISS gt .z,2) 
%categorical(BKGRD1_C7NOMISS,0,&y Dominican,BKGRD1_C7NOMISS gt .z,2) 
%categorical(BKGRD1_C7NOMISS,3,&y Mexican,BKGRD1_C7NOMISS gt .z,2) 
%categorical(BKGRD1_C7NOMISS,4,&y Puerto Rican,BKGRD1_C7NOMISS gt .z,2) 
%categorical(BKGRD1_C7NOMISS,5,&y South American,BKGRD1_C7NOMISS gt .z,2) 
%categorical(BKGRD1_C7NOMISS,1,&y Central American,BKGRD1_C7NOMISS gt .z,2) 
%categorical(BKGRD1_C7NOMISS,6,&y Mixed/Other/Missing,BKGRD1_C7NOMISS gt .z,2)
%continuous(PARITY_V1,Parity,PARITY_V1 gt .z )
%categorical(EDUCATION_C3,1,&y Less than high school,EDUCATION_C3 gt .z,1)
%categorical(EDUCATION_C3,2,&y High school graduate,EDUCATION_C3 gt .z,1)
%categorical(EDUCATION_C3,3,&y Greater than high school,EDUCATION_C3 gt .z,1) 
%categorical(INCOME_C3,1,%str(&y < $30,000),INCOME_C3 gt .z,1)
%categorical(INCOME_C3,2,%str(&y ^{unicode '2265'x} $30,000),INCOME_C3 gt .z,1) 
%categorical(INCOME_C3,3,&y Not reported,INCOME_C3 gt .z,1)
%categorical(MARITAL_STATUS,1,&y Single,MARITAL_STATUS gt .z,1)
%categorical(MARITAL_STATUS,2,&y Married or with a partner,MARITAL_STATUS gt .z,1) 
%categorical(MARITAL_STATUS,3,&y %bquote(Separated, divorced or widowed),MARITAL_STATUS gt .z,1)
%categorical(EMPLOYEDYN,1,&y Yes, EMPLOYEDYN gt .z, 1);
%categorical(EMPLOYEDYN,0,&y No, EMPLOYEDYN gt .z, 1);
%categorical(YRSUS_C3,1,&y < 10 years,YRSUS_C3 gt .z,1)
%categorical(YRSUS_C3,2,%str(&y ^{unicode '2265'x} 10 years),YRSUS_C3 gt .z,1) 
%categorical(YRSUS_C3,3,&y Born in US,YRSUS_C3 gt .z,1)
%continuous(POVPCT,%bquote(Housing, %),POVPCT gt .z ) 
%categorical(N_HC,1,&y Yes,N_HC gt .z,1) 
%categorical(N_HC,0,&y No,N_HC gt .z,1)
%categorical(LANG_PREF,1,&y Spanish,LANG_PREF gt .z,1)
%categorical(LANG_PREF,2,&y English,LANG_PREF gt .z,1)
%continuous(ACCULT_MESA,MESA acculturation,ACCULT_MESA gt .z)
%continuous(AGG_PHYS,Physical health scale,AGG_PHYS gt .z)
%continuous(AGG_MENT,Mental health scale,AGG_MENT gt .z)
%continuous(CESD10,Depressive symptoms,CESD10 gt .z)
%continuous(STAI10,Anxiety,STAI10 gt .z) 
%continuous(BMI,BMI (kg/m2), BMI gt .z) 
%continuous(ANTA10A, Waist Circumference (cm), ANTA10A gt .z)

%categorical(CIGARETTE_USE,1,&y Never,CIGARETTE_USE gt .z,1)
%categorical(CIGARETTE_USE,2,&y Former,CIGARETTE_USE gt .z,1)
%categorical(CIGARETTE_USE,3,&y Current,CIGARETTE_USE gt .z,1)

%continuous(HEI2010,Healthy Eating Index, HEI2010 gt .z)
%continuous(PCT_MVPA,%bquote(% MVPA, min/day), PCT_MVPA gt .z)
%categorical(ALCOHOL_USE,1,&y Never,ALCOHOL_USE gt .z, 1)
%categorical(ALCOHOL_USE,2,&y Former,ALCOHOL_USE gt .z, 1)
%categorical(ALCOHOL_USE,3,&y Current,ALCOHOL_USE gt .z, 1)
%continuous(SLPDUR,Sleep duration, SLPDUR gt .z)
%categorical(PAG2008YN,1,&y Yes,PAG2008YN gt .z, 1) 
%categorical(PAG2008YN,0,&y No,PAG2008YN gt .z, 1)
%categorical(DEMB1,1,&y Boy, DEMB1 gt .z, 1) 
%categorical(DEMB1,2,&y Girl, DEMB1 gt .z, 1) 
%categorical(BMIPCT_C3,1,&y Normal, BMIPCT_C3 gt .z, 1) 
%categorical(BMIPCT_C3,2,&y Overweight, BMIPCT_C3 gt .z, 1) 
%categorical(BMIPCT_C3,3,&y Obese, BMIPCT_C3 gt .z, 1) 
%continuous(WAZ,Weight-for-age z score, WAZ gt .z)
%continuous(BIRTHWT_GA_Z,Birth weight z score, BIRTHWT_GA_Z gt .z) 
run;


data allrows;
    length vartext $100;
    set toplines(where=(line=0)) /* Sociodemographic */ age
        toplines(where=(line=1)) /* Hispanic/Latina background, % */
        BKGRD1_C7NOMISS_2 BKGRD1_C7NOMISS_0 BKGRD1_C7NOMISS_3 BKGRD1_C7NOMISS_4
        BKGRD1_C7NOMISS_5 BKGRD1_C7NOMISS_1 BKGRD1_C7NOMISS_6 PARITY_V1
        toplines(where=(line=2)) /* Education, % */ EDUCATION_C3_1
        EDUCATION_C3_2 EDUCATION_C3_3 toplines(where=(line=3)) /* Income, % */
        income_c3_1 income_c3_2 income_c3_3 toplines(where=(line=4))
        /* Marital status, % */ marital_status_1 marital_status_2
        marital_status_3 toplines(where=(line=5)) /* Employment, % */
        EMPLOYEDYN_1 EMPLOYEDYN_0 toplines(where=(line=6))
        /* Years in the US, % */ yrsus_c3_1 yrsus_c3_2 yrsus_c3_3 POVPCT
        toplines(where=(line=7)) /* Health care access */ N_HC_1 N_HC_0
        toplines(where=(line=8)) /* Acculturation */ toplines(where=(line=9))
        /* Language of Preference, % */ lang_pref_1 lang_pref_2 ACCULT_MESA
        toplines(where=(line=10)) /* Physical and Mental Health */ AGG_PHYS
        AGG_MENT CESD10 STAI10 toplines(where=(line=11)) /* Anthropometry */ BMI
        ANTA10A toplines(where=(line=12)) /* Health Behaviors */
        toplines(where=(line=13)) /* Alcohol Use, % */ ALCOHOL_USE_1
        ALCOHOL_USE_2 ALCOHOL_USE_3 toplines(where=(line=14)) /* Smoking, % */
        CIGARETTE_USE_1 CIGARETTE_USE_2 CIGARETTE_USE_3 
		HEI2010 SLPDUR PCT_MVPA
        toplines(where=(line=15)) /* Phisical activity, % */ PAG2008YN_1
        PAG2008YN_0 toplines(where=(line=16)) /* Child */
        toplines(where=(line=17)) /* Sex, % */ DEMB1_1
        /* is child�s sex (1-boy; 2-girl). */ DEMB1_2 
 		toplines(where=(line=18)) BMIPCT_C3_1 BMIPCT_C3_2 BMIPCT_C3_3 WAZ BIRTHWT_GA_Z ;

    ods rtf file="&homepath.\scripts\&job.\&job._Table1_&sysdate..rtf" bodytitle
        style=journal;
    ods escapechar="^";
    title1
        "Table 1. Maternal Preconception and Child Characteristics among HCHS/SOL women with a child born ^n between baseline (2008-11) and Visit 2 (2014-17), by FLOR participation.";
    options orientation=landscape ;

    ods listing close;

proc report data=allrows nowd style(header)=header{background=lightgray};
    columns vartext ("FLOR dyads ^n (N=&flor_ct)" flor_n flor_p)
        ("Non-FLOR dyads ^n (N=&nonflor_ct)" nonflor_n nonflor_p) pvalue;
    define vartext / display 'Maternal Preconception' left
        style(column)=[cellwidth=3in];
    define flor_n / display 'N' center style(column)=[cellwidth=.4 in];
    define flor_p / display 'Mean (SD) or %' center style(column)=[cellwidth=1.5
        in];
    define nonflor_n / display 'N' center style(column)=[cellwidth=.4 in];
    define nonflor_p / display 'Mean (SD) or %' center
        style(column)=[cellwidth=1.5 in];
    define pvalue / display "P-value" center;
    compute vartext;
    if vartext in ('Sociodemographic', 'Acculturation', 'Anthropometry',
        'Physical and Mental Health', 'Health Behaviors',
        'Child characteristics') THEN do;
        call define (_COL_,"STYLE", "STYLE=[fontweight=BOLD]");
    end;
    endcomp;
run;
title;
ods rtf close;
run;
