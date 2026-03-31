%macro get_all_partial_r2(impdata=, class_vars=, cont_vars=, outds=partial_r2_summary, outcome=waz);

  /* 1. Define the variables to loop through */
  %if %superq(class_vars)= %then %let class_test = bkgrd1_c7nomiss marital_status employedyn education_c3 n_hc 
                    yrsus_c3 current_smoker alcohol_use pag2008yn hei2010_c3 cesd10 stai10 centernum;
  %else %let class_test = &class_vars;

  %if %superq(cont_vars)= %then %let cont_test  = age parity_v1 slpdur child_prs_bmi_a yrs_btwn_v1flor;
  %else %let cont_test = &cont_vars;

  %let all_test = &class_test &cont_test;
  
  /* Suppress model output to keep your results viewer clean */
  ods select none;
  
  /* 2. Run the FULL Model and extract Deviance (SSE) */
  ods output ModelFit=fit_full;
  proc genmod data=&impdata;
    by _imputation_;
    %if %superq(class_test) ne %then %do;
      class &class_test;
    %end;
    model &outcome = &all_test / dist=normal;
    
    /* KEEP FORMATS: Vital to prevent continuous/categorical mismatches */
    format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. 
           marital_status marital_status_fmt. employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. 
           education_c3 education_c3_fmt. alcohol_use alcohol_use_fmt. current_smoker yn_fmt.
           pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.;
  run;
  
  /* Filter strictly for the Deviance row, which represents SSE for dist=normal */
  data sse_full(keep=_imputation_ SSE_F);
    set fit_full;
    where Criterion = "Deviance";
    SSE_F = Value;
  run;
  
  /* 3. Create an empty master dataset with ALL variables defined */
  data all_partial_r2;
    length Dropped_Var $32;
    _imputation_ = .;
    SSE_F = .;
    SSE_R = .;
    Partial_R2 = .;
    stop;
  run;
  
  /* 4. Loop over each variable in the test list */
  %let n_vars = %sysfunc(countw(&all_test));
  
  %do i = 1 %to &n_vars;
    %let drop_v = %scan(&all_test, &i);
    
    /* Build the reduced model lists dynamically */
    %let red_class = ; 
    %let red_model = ;
    
    /* Add back all class variables EXCEPT the current one being dropped */
    %let n_class = %sysfunc(countw(&class_test));
    %do j = 1 %to &n_class;
       %let cv = %scan(&class_test, &j);
       %if "&cv" ^= "&drop_v" %then %do;
          %let red_class = &red_class &cv;
          %let red_model = &red_model &cv;
       %end;
    %end;
    
    /* Add back all continuous variables EXCEPT the current one being dropped */
    %let n_cont = %sysfunc(countw(&cont_test));
    %do k = 1 %to &n_cont;
       %let cov = %scan(&cont_test, &k);
       %if "&cov" ^= "&drop_v" %then %do;
          %let red_model = &red_model &cov;
       %end;
    %end;
    
    /* 5. Run the REDUCED Model and extract Deviance (SSE) */
    ods output ModelFit=fit_red;
    proc genmod data=&impdata;
      by _imputation_;
      %if %superq(red_class) ne %then %do;
        class &red_class;
      %end;
      model &outcome = &red_model / dist=normal;
      
      /* Safely leave all formats here; SAS ignores formats for variables not in the model */
      format centernum centernum_fmt. n_hc n_hc_fmt. bkgrd1_c7nomiss bkgrd1_c7nomiss_fmt. 
            marital_status marital_status_fmt. employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. 
            education_c3 education_c3_fmt. alcohol_use alcohol_use_fmt. current_smoker yn_fmt.
            pag2008yn yn_fmt. hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.;
    run;
    
    data sse_red(keep=_imputation_ SSE_R);
      set fit_red;
      where Criterion = "Deviance";
      SSE_R = Value;
    run;
    
    /* 6. Merge by imputation and calculate Partial R2 */
    data current_r2;
      merge sse_full sse_red;
      by _imputation_;
      length Dropped_Var $32;
      Dropped_Var = "&drop_v";
      
      /* Calculate R2: (SSE_Reduced - SSE_Full) / SSE_Reduced */
      if SSE_R > 0 then Partial_R2 = (SSE_R - SSE_F) / SSE_R;
      else Partial_R2 = .;
    run;
    
    /* Append the result to the master dataset */
    proc append base=all_partial_r2 data=current_r2 force;
    run;
    
  %end; /* End of the loop */
  
  /* Turn output back on */
  ods select all;
  
  /* 7. Summarize the pooled results across imputations */
  proc means data=all_partial_r2 nway noprint;
    class Dropped_Var;
    var Partial_R2;
    output out=&outds(drop=_type_ _freq_) mean=Partial_R2;
  run;

  data &outds;
    set &outds;
    length Dropped_Var $32;
    Dropped_Var = upcase(Dropped_Var);
    Partial_R2_Pct = round(Partial_R2*100, .01);
  run;
  
%mend;
