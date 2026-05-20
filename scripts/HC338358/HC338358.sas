%let req = HC3383;
%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\Manuscripts\MS1560;
%let job = HC338358;
%let datefile = 20may26;
proc printto log="&homepath.\scripts\&job.\&job._&sysdate..log"
    print = "&homepath.\scripts\&job.\&job._&sysdate..lst" new;
run;

/***************************************************************
 *                                                        
 *  SAS PROGRAM - QC DATASET JOB HC3383                   
 *                                                        
 ***************************************************************
 *                                                        
 *  PROGRAM NAME: HC338358.sas                            
 *
 *  PROGRAMMER: Alvaro Quijano (AQ)                       
 *
 *  DESCRIPTION: Logistic model with Overweight/Obese as 
 *               the response. Produces Table 3 (betas)   
 *               and Table 3 OR (odds ratios) within      
 *               the same workflow.                       
 *
 * ---------------------------------------------------------
 *
 *  JOB NUMBER: HC338358                                  
 *
 *  LANGUAGE: SAS 9.4                                      
 *
 *  VERSION CONTROL:                                       
 *               09mar26: create file                      
 *               29apr26: update imputed dataset to 29apr26
 *               20may26: input imputed data *_&datefile (20may26)
 *                        and replace current_smoker with
 *                        cigarette_use in models 2-4.
 *               05may26: add table_num macro variable 
						  update footnote to add the analytic file's job

				 20may26: update input dataset to *_20may26
						  correct script so it finally shows both bts and OR tables

 * ----------------------------------------------------------
 *
 *  INPUT:  data.HC338353_imputed_data_&datefile.          
 *
 *  OUTPUT: Table 3 (betas) and Table 3 OR (odds ratios)   
 *
 ****************************************************************/

options orientation=portrait nodate nonumber nocenter formchar="|----|+|---+=|-/\<>*" ps=59 ls=174 varinitchk=error mprint validvarname=upcase;
ods escapechar '^';

* Set libraries name;
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

* Define macro variables;
%put JOB=&job.;
%let prg = AQA;
%let impdb = data.HC338353_imputed_data_&datefile.;
%let lf_margin = 0.7in;
%let rg_margin = 0.7in;
%let table_num = 3;

* Include SAS scripts with formats and macros;
%include "&homepath.\scripts\HC338390\HC338390.sas";
%include "&homepath.\scripts\HC338391\HC3383_labels.sas";
%include "&homepath.\scripts\HC338391\HC3383_process_imputed.sas";

* Macro to process imputed odds ratios;
%macro process_imputed_or(in_db=, out_db=, model=);
    data &in_db.;
        set &in_db.;
        length EffectName $50;
        if missing(Level1) then EffectName = Parameter;
        else EffectName = catx('_', Parameter, Level1);
    run;

    proc sort data = &in_db.;
        by EffectName;
    run;

    ods output ParameterEstimates = &out_db._p;
    proc mianalyze data = &in_db.;
        by EffectName;
        modeleffects Estimate;
        stderr StdErr;
    run;
    ods output close;

    data &out_db.(keep = order model label or_txt ci_txt pv);
        length model $10 or_txt $20 ci_txt $30;
        set &out_db._p(rename = (EffectName = variable));
        model = &model.;

        %labels;
        if variable not in ('Scale','Intercept');

        if std = 99 then do;
            or_txt = 'Ref.';
            ci_txt = ' ';
        end;
        else do;
            or_txt = strip(put(exp(estimate), 8.2));
            ci_txt = cats('(', strip(put(exp(LCLMean), 8.2)), ', ',
                           strip(put(exp(UCLMean), 8.2)), ')');
        end;
    run;
%mend process_imputed_or;

* Prepare outcome variable in temporary dataset;
data impdb;
    set &impdb.;

    if BMIPCT_C3 in (2,3) then BMIPCT_C2 = 1;
    else if BMIPCT_C3 = 1 then BMIPCT_C2 = 0;
    else BMIPCT_C2 = .;
    label BMIPCT_C2 = 'Respondent is Overweight or Obese';
run;

* Fit the models using the imputed data;
title 'Model 1 - Sociodemographics';
proc genmod data = impdb;
    by _imputation_;
    class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE')
          employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
          yrsus_c3(ref='US_BORN') bmipct_c2(ref='NORMAL');
    model bmipct_c2 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
                       parity_v1 employedyn marital_status yrsus_c3 / dist = binomial;
    format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt.
           marital_status marital_status_fmt. employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt.
           education_c3 education_c3_fmt. bmipct_c2 bmipct_c2_fmt.;
    ods output ParameterEstimates = genmod_results_1;
run;

title 'Model 2: Model 1 + (diet, alcohol, smoke, pa, slpdur)';
proc genmod data = impdb;
    by _imputation_;
    class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE')
          employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
          yrsus_c3(ref='US_BORN') cigarette_use(ref="NEVER") alcohol_use(ref="NEVER")
          pag2008yn(ref="YES") hei2010_c3(ref="LOW") bmipct_c2(ref='NORMAL');
    model bmipct_c2 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
                       parity_v1 employedyn marital_status yrsus_c3 cigarette_use hei2010_c3
                       alcohol_use pag2008yn slpdur / dist = binomial;
    format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt.
           marital_status marital_status_fmt. employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt.
           education_c3 education_c3_fmt. alcohol_use alcohol_use_fmt. cigarette_use cigarette_use_fmt.
           pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt. bmipct_c2 bmipct_c2_fmt.;
    ods output ParameterEstimates = genmod_results_2;
run;

title 'Model 3: Model 2 + mental health';
proc genmod data = impdb;
    by _imputation_;
    class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE')
          employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
          yrsus_c3(ref='US_BORN') cigarette_use(ref="NEVER") alcohol_use(ref="NEVER")
          pag2008yn(ref="YES") hei2010_c3(ref="LOW") cesd10(ref="NODEPRE") stai10(ref="NOANX")
          bmipct_c2(ref='NORMAL');
    model bmipct_c2 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3
                       parity_v1 employedyn marital_status yrsus_c3 cigarette_use hei2010_c3
                       alcohol_use pag2008yn slpdur cesd10 stai10 / dist = binomial;
    format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt.
           marital_status marital_status_fmt. employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt.
           education_c3 education_c3_fmt. alcohol_use alcohol_use_fmt. cigarette_use cigarette_use_fmt.
           pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.
           bmipct_c2 bmipct_c2_fmt.;
    ods output ParameterEstimates = genmod_results_3;
run;

title 'Model 4: Model 3 + PRS';
proc genmod data = impdb;
    by _imputation_;
    class centernum(ref="BRONX") bkgrd1_c7nomiss(ref='MEXICAN') marital_status(ref='SINGLE')
          employedyn(ref="NOT_EMPLOYED") education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO")
          yrsus_c3(ref='US_BORN') cigarette_use(ref="NEVER") alcohol_use(ref="NEVER")
          pag2008yn(ref="YES") hei2010_c3(ref="LOW") cesd10(ref="NODEPRE") stai10(ref="NOANX")
          bmipct_c2(ref='NORMAL');
    model bmipct_c2 = centernum yrs_btwn_v1flor age bkgrd1_c7nomiss n_hc education_c3 parity_v1
                       employedyn marital_status yrsus_c3 cigarette_use hei2010_c3 alcohol_use
                       pag2008yn slpdur cesd10 stai10 child_prs_bmi_a / dist = binomial;
    format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt.
           marital_status marital_status_fmt. employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt.
           education_c3 education_c3_fmt. alcohol_use alcohol_use_fmt. cigarette_use cigarette_use_fmt.
           pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.
           bmipct_c2 bmipct_c2_fmt.;
    ods output ParameterEstimates = genmod_results_4;
run;

* Process the imputed estimates for betas and odds ratios;
%macro summarize_models;
    %do m = 1 %to 4;
        %process_imputed(in_db = genmod_results_&m., out_db = beta_results_&m., model = &m.);
        %process_imputed_or(in_db = genmod_results_&m., out_db = or_results_&m., model = &m.);
    %end;
%mend summarize_models;
%summarize_models;

data table3_beta;
    set beta_results_1 beta_results_2 beta_results_3 beta_results_4;
run;

data table3_beta;
    set table3_beta;
    if std = 99 then estimate = 98;
run;

data table3_or_long;
    set or_results_1 or_results_2 or_results_3 or_results_4;
run;

proc sort data = table3_or_long;
    by order label model;
run;

data table3_or_wide;
    length label $300 or_txt_1-or_txt_4 $40 ci_txt_1-ci_txt_4 $60 pv_1-pv_4 $20;
    retain or_txt_1-or_txt_4 ci_txt_1-ci_txt_4 pv_1-pv_4;

    set table3_or_long;
    by order label;

    if first.label then do;
        call missing(of or_txt_1-or_txt_4);
        call missing(of ci_txt_1-ci_txt_4);
        call missing(of pv_1-pv_4);
    end;

    select (model);
        when (1) do; or_txt_1 = or_txt; ci_txt_1 = ci_txt; pv_1 = pv; end;
        when (2) do; or_txt_2 = or_txt; ci_txt_2 = ci_txt; pv_2 = pv; end;
        when (3) do; or_txt_3 = or_txt; ci_txt_3 = ci_txt; pv_3 = pv; end;
        when (4) do; or_txt_4 = or_txt; ci_txt_4 = ci_txt; pv_4 = pv; end;
        otherwise;
    end;

    if last.label then output;
    keep order label or_txt_: ci_txt_: pv_:;
run;

data table3_or_wide;
    set table3_or_wide;
    sig_1 = (pv_1 in (1,2));
    sig_2 = (pv_2 in (1,2));
    sig_3 = (pv_3 in (1,2));
    sig_4 = (pv_4 in (1,2));
run;

proc sort data = table3_or_wide;
    by order;
run;

* Obtain ids and save it in a macro variable;
proc sql noprint;
    select count(distinct(id)) into :n_ids trimmed from &impdb.;
quit;

* Print final reports;
ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);

%let fs = 11pt;
%let fs_body = 11pt;
%let fs_titles = 11pt;
%let lft_mgn = 0.3in;
%let rgt_mgn = 0.1in;

ods rtf file = "&homepath.\scripts\&job.\&job._Table&table_num._bts_&sysdate..rtf" style = manuscrt bodytitle;
proc report data = table3_beta;
    title j = center height = &fs font = 'times roman' bold
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Table 3. Association among maternal preconception socio-behavioral factors and child's overweight or obese status, HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
    footnote1 j = left height = &fs_titles font = 'times roman'
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Abbreviations: CI, confidence interval; FLOR, Family Lifestyle Outcomes Research; PA, physical activity.";
    footnote2 j = left height = &fs_titles font = 'times roman'
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusted by field center, years between baseline and FLOR visit.";
    footnote3 j = left height = &fs_titles font = 'times roman'
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 2: Model 1 + health behavior predictors adjusted by field center and years between baseline and FLOR visit.";
    footnote4 j = left height = &fs_titles font = 'times roman'
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 3: Model 2 + mental health predictors adjusted by field center and years between baseline and FLOR visit.";
    footnote5 j = left height = &fs_titles font = 'times roman'
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 4: Model 3 + child's obesity genetic risk score.";
    footnote6 j = left height = 10pt font = 'times roman'
        "{\line \line Job &job run by &prg using FLOR data on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))}";
    columns order label model,(estimate std pv);
    define order / order group noprint order = internal;
    define label / display group ' ' style(header)=[fontsize=&fs just=left] style=[fontsize=&fs width=2.5in];
    define model / across ' ' style = [fontsize=&fs];
    define estimate / analysis 'Beta' style=[fontsize=&fs vjust=bottom];
    define std / analysis '(SE)' style=[fontsize=&fs vjust=bottom];
    define pv / analysis ' ' group style=[fontsize=&fs vjust=bottom just=left]
                                   style(header)=[cellpadding=0in cellheight=0in cellspacing=0in];
    format pv pv. std paren. estimate refnum.;
    compute after _page_ / style = [just=left font_size=&fs];
        line "* p <= .10, ** p <= .05, *** p <= .01";
    endcomp;
run;
ods rtf close;

ods rtf file = "&homepath.\scripts\&job.\&job._Table&table_num._or_&sysdate..rtf" style = manuscrt bodytitle;
proc report data = table3_or_wide;
    title j = center height = &fs font = 'times roman' bold
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Table &table_num.. Association among maternal preconception socio-behavioral factors and child's overweight or obese status, HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
    footnote1 j = left height = &fs_titles font = 'times roman'
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Abbreviations: CI, confidence interval; FLOR, Family Lifestyle Outcomes Research; PA, physical activity.";
    footnote2 j = left height = &fs_titles font = 'times roman'
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 1: Sociodemographic & acculturation predictors adjusted by field center, years between baseline and FLOR visit.";
    footnote3 j = left height = &fs_titles font = 'times roman'
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 2: Model 1 + health behavior predictors adjusted by field center and years between baseline and FLOR visit.";
    footnote4 j = left height = &fs_titles font = 'times roman'
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 3: Model 2 + mental health predictors adjusted by field center and years between baseline and FLOR visit.";
    footnote5 j = left height = &fs_titles font = 'times roman'
        "^S={leftmargin=&lft_mgn rightmargin=&rgt_mgn}Model 4: Model 3 + child's obesity genetic risk score.";
    footnote6 j = left height = 10pt font = 'times roman'
        "{\line \line Job &job run by &prg using FLOR analytic file (HC338353) on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))}";
    columns order label
            sig_1 ('Model 1' or_txt_1 ci_txt_1)
            sig_2 ('Model 2' or_txt_2 ci_txt_2)
            sig_3 ('Model 3' or_txt_3 ci_txt_3)
            sig_4 ('Model 4' or_txt_4 ci_txt_4);
    define order / order = internal noprint;
    define label / display "Predictor" style(header)=[fontsize=&fs just=left] style=[fontsize=&fs width=2.5in];
    define or_txt_1 / display "OR" style=[fontsize=&fs vjust=bottom just=center];
    define ci_txt_1 / display "95% CI" style=[fontsize=&fs vjust=bottom just=center];
    define or_txt_2 / display "OR" style=[fontsize=&fs vjust=bottom just=center];
    define ci_txt_2 / display "95% CI" style=[fontsize=&fs vjust=bottom just=center];
    define or_txt_3 / display "OR" style=[fontsize=&fs vjust=bottom just=center];
    define ci_txt_3 / display "95% CI" style=[fontsize=&fs vjust=bottom just=center];
    define or_txt_4 / display "OR" style=[fontsize=&fs vjust=bottom just=center];
    define ci_txt_4 / display "95% CI" style=[fontsize=&fs vjust=bottom just=center];
    define sig_1 / display noprint;
    define sig_2 / display noprint;
    define sig_3 / display noprint;
    define sig_4 / display noprint;
    compute or_txt_1;
        if sig_1 = 1 then call define(_col_, 'style', 'style=[font_weight=bold]');
    endcomp;
    compute ci_txt_1;
        if sig_1 = 1 then call define(_col_, 'style', 'style=[font_weight=bold]');
    endcomp;
    compute or_txt_2;
        if sig_2 = 1 then call define(_col_, 'style', 'style=[font_weight=bold]');
    endcomp;
    compute ci_txt_2;
        if sig_2 = 1 then call define(_col_, 'style', 'style=[font_weight=bold]');
    endcomp;
    compute or_txt_3;
        if sig_3 = 1 then call define(_col_, 'style', 'style=[font_weight=bold]');
    endcomp;
    compute ci_txt_3;
        if sig_3 = 1 then call define(_col_, 'style', 'style=[font_weight=bold]');
    endcomp;
    compute or_txt_4;
        if sig_4 = 1 then call define(_col_, 'style', 'style=[font_weight=bold]');
    endcomp;
    compute ci_txt_4;
        if sig_4 = 1 then call define(_col_, 'style', 'style=[font_weight=bold]');
    endcomp;
run;
ods rtf close;

proc printto; run;
