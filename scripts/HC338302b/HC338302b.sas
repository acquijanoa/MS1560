%let homepath=J:\HCHS\STATISTICS\GRAS\QAngarita\Manuscripts\MS1560;
%LET req=HC3383;
%LET job=&req.02b;
%let datefile= 20may26;
proc printto log="&homepath.\scripts\&job.\&job._&sysdate..log" print= "&homepath.\scripts\&job.\&job._&sysdate..lst" new;
run;
******************************************************************
  REQUEST:       HC3383

  TITLE:         MS#1560 Association of preconception socio-behavioral factors and child's weight by Siega-Riz

  DESCRIPTION:   -  Create an analytic data file for MS #1560 "Association of preconception socio-behavioral factors 
                   and child's weight in the HCHS/SOL studies [Grant's aim #2]
                 -  The statistical analyses and tables will be done by GRA Alvaro under Daniela's supervision.

  MANUSCRIPT:    HCM1560

  PROGRAMMER:    Dan Piston
                 edited by: Alvaro Quijano (AQA)  

  REQUESTOR:     Daniela Sotres/Alvaro Quijano

  DATE:          4/23/2025
-----------------------------------------------------------------
  JOB NUMBER:    HC338302b

  DESCRIPTION:   Create Table 1. Maternal Preconception and Child Characteristics among HCHS/SOL women with a 
                 child born between baseline (2008-11) and Visit 2 (2014-17), by FLOR participation.
                 Collapsed Hispanic/Latino background (3 categories) and marital status
                 (2 categories), aligned with model jobs 54b-64b.
            
  LANGUAGE:      SAS VERSION 9.4

  HISTORY:       HC338301 6/23/25 - uccdjp Cont #2 - 
                        Create Table 1 (Section D) using HC338301_ALL data
                        The mean/% and standard deviation (SD) do not account for the HCHS/SOL study design.
                    	The table indicates which variables to use (in red).
                    	Include the categories from the data dictionary for the categorical variables.
                    	Use job HC3131903 as starting point but using the variables relavant to this manuscript
					
				20may26 (AQA)
						update label to 'Health Insurance' instead of 'Healthcare access'.
						include child bmi (groups) and cigarette_use in Table 1
						exclude current_smoker 
				
				05may26	(AQA)
						update input dataset to 20may26
						uses flag variable keep_ms1560 instead of flor_dyad
						add complete/incomplete anthropometry to the table's header

				24jun26 (AQA)
						Copy from HC338302 -- collapse Hispanic/Latino background
						to 3 categories and marital status to 2 categories.
						child sex -- show % and p-value for FLOR and non-FLOR columns
						replace WAZ with BMI-for-age z score (BMIZ)
						reorder child rows -- birthweight z before BMI category
						drop income, housing %, acculturation, and % MVPA from table
						Mental health section -- CESD-10 and STAI-10 only
						drop anthropometry section (BMI, waist circumference)
						replace continuous HEI-2010 with categorical HEI2010_C3
						update sleep duration row label
						update BMI group level labels with superscript th

  NOTE:          Related: HC3139 - MS1207 [FLOR grant aim #1] Uses final INV1 data and MI
-----------------------------------------------------------------

  INPUT:         HC338301_ALL data
                
  OUTPUT:        J:\HCHS\SC\&prog\&req\HC338301_TN1
 
*------------------------------------------------------------------
*******************************************************************;
OPTIONS ps=59 ls=max nodate nonumber MPRINT errors=50 orientation=landscape;
%LET prog=AQA;

* macro variable;
%let home=J:\HCHS\SC\&prog.\&req.;
%put JOB=&job.;
libname mylib "&homepath.\data";
libname flor 'J:\HCHS\SC\Sasdata\Ancillary\SOL FLOR\INV_Use\Datasets';

%include "&homepath.\scripts\HC3383XX\HC3383XX.sas";

* %let workspace = J:\HCHS\SC\&prog.\&req.;
data all;
    set mylib.hc338351_all_&datefile.;
run;

data child;
    set flor.demb_inv2(keep=ID DEMB1); /* DEMB1 = CHILD_SEX */
run;

data repdata;
    merge all (in=want) child;
    by id;
    if want;
    length bkgrd_c3 marital_c2 8;
    if not missing(bkgrd1_c7nomiss) then do;
        if bkgrd1_c7nomiss = 3 then bkgrd_c3 = 1;
        else if bkgrd1_c7nomiss in (0, 2, 4) then bkgrd_c3 = 2;
        else if bkgrd1_c7nomiss in (1, 5, 6) then bkgrd_c3 = 3;
    end;
    if not missing(marital_status) then do;
        if marital_status = 1 then marital_c2 = 1;
        else if marital_status in (2, 3) then marital_c2 = 2;
    end;
    format bkgrd1_c7nomiss bkgrd1_c3nomiss_fmt. marital_status marital_status_c2_fmt.;
run;

data _null_;
    call symput('x',LEFT(INPUT("A0",$hex2.))) ;
RUN;
%LET y=&x&x&x;

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

    line=10;
    vartext='Mental health';
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

    line=11;
    vartext='Diet (Healthy Eating Index), %';
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
    vartext='BMI group, %';
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
        tables keep_ms1560*&var / missing outpct out=myout(keep=keep_ms1560 &var
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
        id keep_ms1560;
        var cp_n;
    run;

    proc transpose data=cp prefix=flor_dyad suffix=_p out=&var.pct
        (drop=_name_);
        by &var;
        id keep_ms1560;
        var cp_pct;
    run;

    /*combine and add final touches*/
    data &var._&varlevel;
        length vartext $200 var $50;
        merge &var.n &var.pct;
        by &var;
        vartext="&text";
        var="&var";

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

    PROC FREQ data=repdata;
        table &catvar*keep_ms1560 / chisq;
        ods output ChiSq=chisq_out (where=(Statistic="Chi-Square")
            rename=(prob=p));
    run;

    proc sql;
        select strip(put(p,pvalue6.3)) into :pcat trimmed from chisq_out;
    quit;
    %put pcat &pcat;

    data chisq_&catvar;
        length var $50 pvalue $15;
        set chisq_out;
        var="&catvar";
        pvalue=strip("&pcat");
        keep var pvalue;
    run;

 %if %upcase(&catvar)=BMIPCT_C3 %then %do;
	data chisq_&catvar;
		set chisq_&catvar;
		nonflor_n='';
        nonflor_p='';
        pvalue='**';
	run;
%end;

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
        class keep_ms1560;
        var &var;
        output out=meansout /autoname;
    run;

    data suffix;
        length statistic $20;
        set meansout;
        if keep_ms1560=0 then do;
            if _stat_='N' then statistic='n_nonflor';
            if _stat_='STD' then statistic='std_nonflor';
            if _stat_='MEAN' then statistic='mean_nonflor';
        end;
        if keep_ms1560=1 then do;
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

    proc contents;
    run;

    proc transpose data=suffix out=t(drop=_name_ );
        id statistic;
        var value;
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

            flor_p=strip(mean_flor) || ' (' || strip(std_flor) || ')';
            vartext="&text";

            keep vartext pvalue nonflor_p flor_p n_nonflor n_flor ;

            rename n_nonflor=nonflor_n n_flor=flor_n ;

            %if %upcase(&var)=BMIPCT_C3 or %upcase(&var)=BMIZ %then %do;
                n_nonflor='';
                nonflor_p='';
                pvalue='**';
            %end;
            %else %do;
                nonflor_p=strip(mean_nonflor) || ' (' || strip(std_nonflor) ||
                    ')';
                pvalue=strip("&pcont");
            %end;

        run;

    %end;

%mend;


%macro model_cont(contvar);
    %global pcont;

    PROC GLM data=repdata;
        class keep_ms1560;
        model &contvar=keep_ms1560;
        ods output ModelANOVA=anovaout(where=(HypothesisType=1) ) ;
    quit;

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
    keep_ms1560=9;
    output;
run;

proc freq;
    table keep_ms1560;
run;

* for header N's;
proc freq data=derive2;
    tables keep_ms1560/out=keep_ms1560_counts(keep=keep_ms1560 count);

/*proc contents data=derive2; run;*/

* store keep_ms1560 counts for use later in header;
data _null_;
    set keep_ms1560_counts;
    if keep_ms1560=0 then call symput('nonflor_ct',strip(put(count,8.)));
    if keep_ms1560=1 then call symput('flor_ct',strip(put(count,8.)));
    if keep_ms1560=9 then call symput('overall_ct',strip(put(count,8.)));
run;

%continuous(age,%bquote(Age (yrs)),age gt .z) 
%categorical(BKGRD_C3,1,&y Mexican,BKGRD_C3 gt .z,1) 
%categorical(BKGRD_C3,2,&y Caribbean,BKGRD_C3 gt .z,1) 
%categorical(BKGRD_C3,3,&y Central and South America/Other,BKGRD_C3 gt .z,1)
%continuous(PARITY_V1,Parity,PARITY_V1 gt .z )
%categorical(EDUCATION_C3,1,&y Less than high school,EDUCATION_C3 gt .z,1)
%categorical(EDUCATION_C3,2,&y High school graduate,EDUCATION_C3 gt .z,1)
%categorical(EDUCATION_C3,3,&y Greater than high school,EDUCATION_C3 gt .z,1) 
%categorical(MARITAL_C2,1,&y Single,MARITAL_C2 gt .z,1)
%categorical(MARITAL_C2,2,%bquote(&y Cohabiting, separated, other),MARITAL_C2 gt .z,1)
%categorical(EMPLOYEDYN,1,&y Yes, EMPLOYEDYN gt .z, 1);
%categorical(EMPLOYEDYN,0,&y No, EMPLOYEDYN gt .z, 1);
%categorical(YRSUS_C3,1,&y < 10 years,YRSUS_C3 gt .z,1)
%categorical(YRSUS_C3,2,%str(&y ^{unicode '2265'x} 10 years),YRSUS_C3 gt .z,1) 
%categorical(YRSUS_C3,3,&y Born in US,YRSUS_C3 gt .z,1)
%categorical(N_HC,1,&y Yes,N_HC gt .z,1) 
%categorical(N_HC,0,&y No,N_HC gt .z,1)
%continuous(CESD10,Depressive symptoms,CESD10 gt .z)
%continuous(STAI10,Anxiety,STAI10 gt .z) 
%categorical(CIGARETTE_USE,1,&y Never,CIGARETTE_USE gt .z,1)
%categorical(CIGARETTE_USE,2,&y Former,CIGARETTE_USE gt .z,1)
%categorical(CIGARETTE_USE,3,&y Current,CIGARETTE_USE gt .z,1)

%categorical(HEI2010_C3,1,%str(&y Low (<=50.1)),HEI2010_C3 gt .z,1)
%categorical(HEI2010_C3,2,%str(&y Medium (>50.1-62.5)),HEI2010_C3 gt .z,1)
%categorical(HEI2010_C3,3,%str(&y High (>62.5)),HEI2010_C3 gt .z,1)
%categorical(ALCOHOL_USE,1,&y Never,ALCOHOL_USE gt .z, 1)
%categorical(ALCOHOL_USE,2,&y Former,ALCOHOL_USE gt .z, 1)
%categorical(ALCOHOL_USE,3,&y Current,ALCOHOL_USE gt .z, 1)
%continuous(SLPDUR,%str(Sleep duration (>8 hrs/day)), SLPDUR gt .z)
%categorical(PAG2008YN,1,&y Yes,PAG2008YN gt .z, 1) 
%categorical(PAG2008YN,0,&y No,PAG2008YN gt .z, 1)
%categorical(DEMB1,1,&y Boy, DEMB1 gt .z, 1) 
%categorical(DEMB1,2,&y Girl, DEMB1 gt .z, 1) 
%continuous(BIRTHWT_GA_Z,Birth weight-for-gestational-age z score, BIRTHWT_GA_Z gt .z)
%categorical(BMIPCT_C3,1,%str(&y Normal (lower than 85^{super th} percentile)), BMIPCT_C3 gt .z, 1) 
%categorical(BMIPCT_C3,2,%str(&y Overweight (85^{super th} to less than 95^{super th} percentile)), BMIPCT_C3 gt .z, 1) 
%categorical(BMIPCT_C3,3,%str(&y Obese (95^{super th} percentile or over)), BMIPCT_C3 gt .z, 1) 
%continuous(BMIZ,BMI-for-age z score, BMIZ gt .z)
run;

data allrows;
    length vartext $100;
    set toplines(where=(line=0)) /* Sociodemographic */ age
        toplines(where=(line=1)) /* Hispanic/Latina background, % */
        BKGRD_C3_1 BKGRD_C3_2 BKGRD_C3_3 PARITY_V1
        toplines(where=(line=2)) /* Education, % */ EDUCATION_C3_1
        EDUCATION_C3_2 EDUCATION_C3_3 toplines(where=(line=4))
        /* Marital status, % */ marital_c2_1 marital_c2_2 toplines(where=(line=5)) /* Employment, % */
        EMPLOYEDYN_1 EMPLOYEDYN_0 toplines(where=(line=6))
        /* Years in the US, % */ yrsus_c3_1 yrsus_c3_2 yrsus_c3_3
        toplines(where=(line=7)) /* Health insurance */ N_HC_1 N_HC_0
        toplines(where=(line=10)) /* Mental health */ CESD10 STAI10
        toplines(where=(line=12)) /* Health Behaviors */
        toplines(where=(line=13)) /* Alcohol Use, % */ ALCOHOL_USE_1
        ALCOHOL_USE_2 ALCOHOL_USE_3 toplines(where=(line=14)) /* Smoking, % */
        CIGARETTE_USE_1 CIGARETTE_USE_2 CIGARETTE_USE_3
        toplines(where=(line=11)) /* Diet */ HEI2010_C3_1 HEI2010_C3_2 HEI2010_C3_3
		SLPDUR
        toplines(where=(line=15)) /* Phisical activity, % */ PAG2008YN_1
        PAG2008YN_0 toplines(where=(line=16)) /* Child */
        toplines(where=(line=17)) /* Sex, % */ DEMB1_1 DEMB1_2
        BIRTHWT_GA_Z
 		toplines(where=(line=18)) BMIPCT_C3_1 BMIPCT_C3_2 BMIPCT_C3_3 BMIZ ;

    ods rtf file="&homepath.\scripts\&job.\&job._Table1_&sysdate..rtf" bodytitle
        style=journal;
    ods escapechar="^";
    * title1
        "Table 1. Maternal Preconception and Child Characteristics among HCHS/SOL women with a child born ^n between baseline (2008-11) and Visit 2 (2014-17), by FLOR participation.";
    title1 j=left 
        "^S={leftmargin=1.5in}Table 1. Maternal Preconception and Child Characteristics among HCHS/SOL women with a child born ^n after baseline (2008-11) by availability of child's anthropometry.";
    options orientation=landscape ;

    ods listing close;

    footnote1 j=left height=10pt font='times roman'
        "^S={leftmargin=1.5in}Abbreviations: BMI, body mass index; MVPA, moderate-to-vigorous physical activity; PA, physical activity.";
    footnote2 j=left height=10pt font='times roman'
        "{\line \line Job &job run by &prog on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))}";

proc report data=allrows nowd style(header)=header{background=lightgray};
    columns vartext ("FLOR dyads ^n and complete ^n anthropometry ^n (N=&flor_ct)" flor_n flor_p)
        ("Non-FLOR dyads ^n or incomplete ^n anthropometry ^n (N=&nonflor_ct)" nonflor_n nonflor_p) pvalue;
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
    if vartext in ('Sociodemographic', 'Mental health',
        'Health Behaviors', 'Child characteristics') THEN do;
        call define (_COL_,"STYLE", "STYLE=[fontweight=BOLD]");
    end;
    endcomp;
run;
title;
ods rtf close;
run;
