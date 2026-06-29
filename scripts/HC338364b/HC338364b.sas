%let req=HC3383;
%let homepath = J:\HCHS\STATISTICS\GRAS\QAngarita\Manuscripts\MS1560;
%let job = &req.64b;
%let datefile = 29jun26;
proc printto log="&homepath.\scripts\&job.\&job._&sysdate..log"
	print = "&homepath.\scripts\&job.\&job._&sysdate..lst" new;
run;
/*********************************************************
*
*  SAS PROGRAM - JOB HC338364b
*
**********************************************************
*
*  PROGRAM NAME: HC338364b.sas
*
*  PROGRAMMER: Alvaro Quijano (AQA)
*
*  MANUSCRIPT: MS1560
*
*  DESCRIPTION: [copy from job 64] Multinomial logistic (generalized logit) for BMIPCT_C3 with multiply-imputed
*               data. Only Model 4 (full covariate set from HC338365). Reference category:
*               Normal. Odds ratios with 95% Wald CIs for Overweight vs Normal, Obesity vs
*               Normal, and Obesity vs Overweight. 
*				
*
*  JOB NUMBER: HC338364
*
*  LANGUAGE: SAS 9.4
*
*  VERSION CONTROL:
*       05may26: Initial version from HC338365 Model 4 + HC313953 OR method.
*       13may26: Use PROC LOGISTIC DESCENDING with BMIPCT_C3_V3 as unformatted numeric
*                outcome and UNEQUALSLOPES.
*		20may26: update input dataset to *_20may26
*                Initialize MODEL before %labels (fixes uninitialized MODEL error).
*                Replace cumulative logit / unequal slopes with multinomial logistic
*                (link=glogit, BMIPCT_C3 reference Normal).
*                Revise table footnotes to MS1560 abbreviation, model, and footer standards.
*
*		24jun26: updates formats for backgroud and marital status.
*				 Marital status reference = Single/separated/other.
*				 Collapse cigarette_use to never vs current or former (cigarette_use_c2_fmt).
*                Revise table footnotes.
*		29jun26: Input HC338353b imputed data; use derived collapsed covariates.
*
*  INPUT: HC338353b_imputed_data_&datefile.
*
*  OUTPUT: &job._Table4_&sysdate..rtf
*
**********************************************************/
options orientation=portrait ps=59 ls=173 nodate nonumber
        formchar="|----|+|---+=|-/\<>*" mprint varinitchk=error
        validvarname=upcase;
ods escapechar '^';

* Set libraries; 
libname data "&homepath.\data";
libname hchstyle 'J:\hchs\sc\styledef\sty904';

* Define macro variables; 
%let prg = AQA;
%let impdb = data.HC338353b_imputed_data_&datefile.;
%let lf_margin = 0.6in;
%let rg_margin = 0.7in;
%let table_num = 4;

* Includes required scripts for reporting;
%include "&homepath.\scripts\HC3383XX\HC3383XX.sas";
%include "&homepath.\scripts\HC338391\HC3383_labels.sas";

* Creates input dataset;
data logistic_input / view = logistic_input;
	set &impdb.(where = (keep_ms1560));
run;

* Model 4 only: multinomial logistic (generalized logit), reference = Normal;
title 'Model 4 (complete): Multinomial logistic (generalized logit)';
proc logistic data = logistic_input plots=none;
	by _imputation_;
	class bmipct_c3(ref='Normal') centernum(ref="BRONX") bkgrd1_c3nomiss(ref='MEXICAN')
		marital_status_c2(ref='SINGLE_OTHER') employedyn(ref="NOT_EMPLOYED")
		education_c3(ref='N_HIGHSCHOOL_GED') n_hc(ref="NO") yrsus_c3(ref='US_BORN')
		cigarette_use_c2(ref="NEVER") alcohol_use(ref="NEVER") pag2008yn(ref="YES")
		hei2010_c3(ref="LOW") cesd10(ref="NODEPRE") stai10(ref="NOANX") / param = ref;
	model BMIPCT_C3 = centernum yrs_btwn_v1flor bkgrd1_c3nomiss age n_hc education_c3 parity_v1
		employedyn marital_status_c2 yrsus_c3 cigarette_use_c2 hei2010_c3 alcohol_use pag2008yn slpdur
		cesd10 stai10 child_prs_bmi_a / link = glogit expb clodds = wald covb;
	format BMIPCT_C3 bmipct_c3_fmt. centernum centernum_fmt. n_hc n_hc_fmt.
		bkgrd1_c3nomiss bkgrd1_c3_fmt. marital_status_c2 marital_status_c2_fmt.
		employedyn employedyn_fmt. yrsus_c3 yrsus_c3_fmt. education_c3 education_c3_fmt.
		alcohol_use alcohol_use_fmt. cigarette_use_c2 cigarette_use_c2_fmt. pag2008yn yn_fmt.
		hei2010_c3 hei2010_c3_fmt. cesd10 cesd10_fmt. stai10 stai10_fmt.;
	ods output ParameterEstimates = estimate_raw CovB = covb_raw;
run;

data estimate_order;
	set estimate_raw;
	retain RowInImp last_imp;
	if _n_ = 1 | _Imputation_ ne last_imp then RowInImp = 0;
	RowInImp + 1;
	last_imp = _Imputation_;
	drop last_imp;
run;

proc sort data = estimate_raw out = est_keys nodupkey;
	where DF >= 1 & ^missing(Estimate) & StdErr > 0
		& upcase(Variable) not in ('INTERCEPT');
	by Variable ClassVal0 Response;
run;

data parm_key;
	length parm $8 EffectKey $132 LabelBase $132;
	set est_keys;
	ParmNum = _n_;
	parm = cats('PARM', ParmNum);
	EffectKey = cats(Variable, ClassVal0, '_', Response);
	LabelBase = catx('_', Variable, ClassVal0);
	keep parm ParmNum EffectKey LabelBase Variable ClassVal0 Response;
run;

proc sort data = estimate_order;
	by Variable ClassVal0 Response;
run;

data estimate_covmap;
	merge estimate_order(in = a) parm_key(in = b);
	by Variable ClassVal0 Response;
	if a & b;
	keep _Imputation_ RowInImp parm EffectKey LabelBase Response;
run;

proc sort data = estimate_raw;
	by Variable ClassVal0 Response;
run;

proc sort data = parm_key;
	by Variable ClassVal0 Response;
run;

data estimate;
	length Variable $32 EffectKey $132 LabelBase $132 RespLab $20;
	merge estimate_raw(in = a) parm_key(in = b);
	by Variable ClassVal0 Response;
	if a;
	if DF < 1 then delete;
	if upcase(Variable) = 'INTERCEPT' then delete;
	if missing(Estimate) | StdErr = 0 then delete;
	if ^b then delete;
	RespLab = strip(vvalue(Response));
	EffectKey = cats(Variable, ClassVal0, '_', Response);
	LabelBase = catx('_', Variable, ClassVal0);
	Variable = parm;
	keep _Imputation_ Variable EffectKey LabelBase RespLab Estimate StdErr WaldChiSq ProbChiSq DF;
run;

proc sort data = estimate nodupkey;
	by _Imputation_ Variable;
run;

data estimate_covmap2;
	set estimate_covmap(rename = (parm = Variable));
run;

proc sort data = estimate_covmap2;
	by _Imputation_ Variable;
run;

data estimate_cov;
	length base $132 lr $80;
	merge estimate(in = a) estimate_covmap2(keep = _Imputation_ Variable RowInImp);
	by _Imputation_ Variable;
	if a;
	base = LabelBase;
	lr = lowcase(strip(RespLab));
	if (lr in ('2', 'overweight') | lr =: 'overweight' | index(lr, 'overweight') > 0)
		& ^(lr in ('3', 'obese') | lr =: 'obese') then RespType = 2;
	else if lr in ('3', 'obese') | lr =: 'obese' then RespType = 3;
	else delete;
	keep _Imputation_ Variable base RespType Estimate RowInImp;
run;

proc sort data = estimate(keep = Variable EffectKey LabelBase RespLab) out = parm_xwalk nodupkey;
	by Variable EffectKey LabelBase RespLab;
run;

data parm_xwalk;
	length Variable $ 32;
	set parm_xwalk;
run;

proc sql noprint;
	select parm into :model_var separated by ' ' 
	from parm_key
	order by ParmNum;
quit;

* Refactor COVB to the same parameter names used by PROC MIANALYZE;
proc contents data = covb_raw out = covb_cols(keep = name type varnum) noprint;
run;

proc sort data = covb_cols;
	by varnum;
run;

data covb_cols;
	set covb_cols;
	where type = 1 & upcase(name) ne '_IMPUTATION_';
	RowInImp + 1;
	OldName = nliteral(name);
	keep RowInImp OldName;
run;

proc sort data = covb_cols;
	by RowInImp;
run;

proc sort data = estimate_covmap2(keep = RowInImp Variable) out = covb_effects nodupkey;
	by RowInImp Variable;
run;

proc sort data = covb_effects nodupkey;
	by RowInImp;
run;

data covb_colmap;
	merge covb_cols(in = a) covb_effects(in = b);
	by RowInImp;
	if a & b;
	RenamePair = catx('=', OldName, Variable);
run;

proc sql noprint;
	select RenamePair into :covb_rename separated by ' '
	from covb_colmap;
quit;

data covb_rows;
	set estimate_covmap2(rename = (Variable = Effect));
	keep _Imputation_ RowInImp Effect;
run;

proc sort data = covb_rows;
	by _Imputation_ RowInImp;
run;

data covb_mi_pre;
	set covb_raw;
	retain RowInImp last_imp;
	if _n_ = 1 | _Imputation_ ne last_imp then RowInImp = 0;
	RowInImp + 1;
	last_imp = _Imputation_;
	drop last_imp;
	rename &covb_rename.;
run;

proc sort data = covb_mi_pre;
	by _Imputation_ RowInImp;
run;

data covb_mi;
	length Effect $32;
	merge covb_mi_pre(in = a) covb_rows(in = b);
	by _Imputation_ RowInImp;
	if a & b;
	keep _Imputation_ Effect &model_var.;
run;

proc sort data = covb_mi;
	by _Imputation_ Effect;
run;

* Combine MI estimates using the refactored covariance matrix;
ods listing close;
ods select none;
proc mianalyze parms = estimate(rename = (Variable = Effect)) covb = covb_mi;
	modeleffects &model_var.;
	ods output ParameterEstimates = betas_mi;
run;
ods select all;

* Recover EffectKey / LabelBase from pooled Parm (betas_mi keeps Estimate StdErr Probt from MIANALYZE only);
proc sort data = betas_mi; by Parm; run;
proc sort data = parm_xwalk; by Variable; run;
data betas_mx;
	length Variable $ 32 base $ 132;
	merge betas_mi(in = a rename = (Parm = Variable))
		parm_xwalk(in = b);
	by Variable;
	if a;
	base = LabelBase;
run;

* Rename on SET so KEEP sees Estimate2/3 (KEEP after RENAME statement does not apply to PDV names — estimates were dropped);
* Split pooled parms by multinomial logit (Overweight vs Normal, Obese vs Normal);
data betas_mi2;
	length base $132;
	length lr $80;
	set betas_mx(rename = (Estimate = Estimate2 StdErr = StdErr2 Probt = Probt2));
	lr = lowcase(strip(RespLab));
	if (lr in ('2', 'overweight') | lr =: 'overweight' | index(lr, 'overweight') > 0)
		& ^(lr in ('3', 'obese') | lr =: 'obese') then output;
	keep base Estimate2 StdErr2 Probt2 EffectKey RespLab;
run;

data betas_mi3;
	length base $132;
	length lr $80;
	set betas_mx(rename = (Estimate = Estimate3 StdErr = StdErr3 Probt = Probt3));
	lr = lowcase(strip(RespLab));
	if lr in ('3', 'obese') | lr =: 'obese' then output;
	keep base Estimate3 StdErr3 Probt3 EffectKey RespLab;
run;

* Rubin total covariance for the Obese vs Overweight contrast, using PROC LOGISTIC COVB directly;
proc iml;
	use covb_raw;
	read all var {_Imputation_} into ImpCov;
	read all var _NUM_ into CAll[colname = CovNames];
	close covb_raw;
	keepCols = loc(upcase(CovNames) ^= '_IMPUTATION_');
	CAll = CAll[, keepCols];

	use estimate_cov;
	read all var {_Imputation_ RowInImp RespType Estimate} into E;
	read all var {base} into Base;
	close estimate_cov;

	UBase = unique(Base);
	OutBase = t(UBase);
	StdErr32 = j(nrow(OutBase), 1, .);

	do b = 1 to nrow(OutBase);
		idxBase = loc(Base = OutBase[b]);
		if ncol(idxBase) = 0 then continue;
		ImpBase = unique(E[idxBase, 1]);
		QDiff = j(ncol(ImpBase), 1, .);
		WDiff = j(ncol(ImpBase), 1, .);
		nUse = 0;

		do j = 1 to ncol(ImpBase);
			imp = ImpBase[j];
			idxOW = loc(Base = OutBase[b] & E[, 1] = imp & E[, 3] = 2);
			idxOB = loc(Base = OutBase[b] & E[, 1] = imp & E[, 3] = 3);
			idxCov = loc(ImpCov = imp);
			if ncol(idxOW) = 1 & ncol(idxOB) = 1 & ncol(idxCov) > 0 then do;
				rowOW = E[idxOW, 2];
				rowOB = E[idxOB, 2];
				nUse = nUse + 1;
				QDiff[nUse] = E[idxOB, 4] - E[idxOW, 4];
				WDiff[nUse] = CAll[idxCov[rowOB], rowOB] + CAll[idxCov[rowOW], rowOW]
					- 2 * CAll[idxCov[rowOB], rowOW];
			end;
		end;

		if nUse > 0 then do;
			QDiff = QDiff[1:nUse];
			WDiff = WDiff[1:nUse];
			Between = 0;
			if nUse > 1 then Between = var(QDiff);
			TotalVar = mean(WDiff) + (1 + 1 / nUse) * Between;
			if TotalVar >= 0 then StdErr32[b] = sqrt(TotalVar);
		end;
	end;

	base = OutBase;
	create contrast_cov var {'base' 'StdErr32'};
	append;
	close contrast_cov;
quit;

proc sort data = betas_mi2;
	by base;
run;

proc sort data = betas_mi3;
	by base;
run;

proc sort data = contrast_cov;
	by base;
run;

data merged_core;
	merge betas_mi2 betas_mi3 contrast_cov;
	by base;
run;

* Reference CLASS levels have no rows in ParameterEstimates insert stubs so %labels can emit section headers + ref titles;
data ref_pad;
	length base $132 EffectKey $132 RespLab $20;
	length Estimate2 StdErr2 Probt2 Estimate3 StdErr3 Probt3 StdErr32 8;
	call missing(Estimate2, StdErr2, Probt2, Estimate3, StdErr3, Probt3, StdErr32);
	EffectKey = '';
	RespLab = '';
	base = 'CENTERNUM_BRONX';
	output;
	base = 'BKGRD1_C7NOMISS_MEXICAN';
	output;
	base = 'N_HC_NO';
	output;
	base = 'EDUCATION_C3_N_HIGHSCHOOL_GED';
	output;
	base = 'EMPLOYEDYN_NOT_EMPLOYED';
	output;
	base = 'MARITAL_STATUS_SINGLE_OTHER';
	output;
	base = 'YRSUS_C3_US_BORN';
	output;
	base = 'CIGARETTE_USE_NEVER';
	output;
	base = 'ALCOHOL_USE_NEVER';
	output;
	base = 'PAG2008YN_YES';
	output;
	base = 'HEI2010_C3_LOW';
	output;
	base = 'CESD10_NODEPRE';
	output;
	base = 'STAI10_NOANX';
	output;
run;

data merged;
	set merged_core ref_pad;
run;

proc sort data = merged nodupkey;
	by base;
run;

data prelabel;
	set merged;
	variable = upcase(base);
	estimate = Estimate2;
	stderr = StdErr2;
	probt = Probt2;
run;

data labeled;
	set prelabel;
	length label $150 v $132 model $10;
	order = .;
	label = '';
	model = 'Model 4';
	%labels;
	if label = '' then do;
		v = strip(upcase(variable));
		if v =: 'YRSUS_C3_' & index(v, 'US_BORN') = 0 then do;
			if index(v, '<10') > 0 | index(v, 'L10') > 0 then do;
				order = 12.1;
				label = "^S={indent=2mm} <10 years";
			end;
			else do;
				order = 12.2;
				label = "^S={indent=2mm} >=10 years";
			end;
		end;
	end;
	drop v;
	keep base order label Estimate2 StdErr2 Probt2 Estimate3 StdErr3 Probt3 StdErr32 variable;
run;

proc sort data = labeled;
	by order label base;
run;

* Format odds ratios and 95% CIs without PROC IML;
data ORchars;
	length base $132 statsOW statsOB statsOBvsOW $168;
	set labeled(keep = base Estimate2 StdErr2 Estimate3 StdErr3 StdErr32);

	statsOW = ' ';
	statsOB = ' ';
	statsOBvsOW = ' ';

	if missing(Estimate2) & missing(Estimate3) then return;
	else if missing(Estimate2) | missing(Estimate3) then do;
		statsOW = '---';
		statsOB = '---';
		statsOBvsOW = '---';
		return;
	end;

	if nmiss(Estimate2, StdErr2) = 0 then do;
		or2 = exp(Estimate2);
		lc2 = exp(Estimate2 - 1.96 * StdErr2);
		uc2 = exp(Estimate2 + 1.96 * StdErr2);
		statsOW = cats(put(or2, 8.2), ' (', put(lc2, 8.2), ', ', put(uc2, 8.2), ')');
	end;
	else statsOW = '---';

	if nmiss(Estimate3, StdErr3) = 0 then do;
		or3 = exp(Estimate3);
		lc3 = exp(Estimate3 - 1.96 * StdErr3);
		uc3 = exp(Estimate3 + 1.96 * StdErr3);
		statsOB = cats(put(or3, 8.2), ' (', put(lc3, 8.2), ', ', put(uc3, 8.2), ')');
	end;
	else statsOB = '---';

	if nmiss(Estimate2, Estimate3) = 0 then do;
		diff32 = Estimate3 - Estimate2;
		if missing(StdErr32) then se32 = sqrt(StdErr2 ** 2 + StdErr3 ** 2);
		else se32 = StdErr32;
		if nmiss(diff32, se32) = 0 then do;
			or32 = exp(diff32);
			lc32 = exp(diff32 - 1.96 * se32);
			uc32 = exp(diff32 + 1.96 * se32);
			statsOBvsOW = cats(put(or32, 8.2), ' (', put(lc32, 8.2), ', ', put(uc32, 8.2), ')');
		end;
		else statsOBvsOW = '---';
	end;
	else statsOBvsOW = '---';

	keep base statsOW statsOB statsOBvsOW;
run;

data ORchars;
	length base $132;
	set ORchars;
	base = strip(base);
run;

* MERGE BY base requires both sets sorted by base (labeled was PROC SORT order label base for %labels);
proc sort data = labeled;
	by base;
run;

proc sort data = ORchars;
	by base;
run;

data db_join;
	merge labeled(keep = order label base Estimate2 StdErr2 Estimate3 StdErr3 StdErr32)
		ORchars;
	by base;
run;

* Significance: 95% Wald CI on OR scale excludes 1. Keep flags for PROC REPORT styling;
data db_join;
	length statsOW statsOB statsOBvsOW $168;
	length lc2 uc2 lc3 uc3 lc32 uc32 8;
	set db_join;
	call missing(lc2, uc2, lc3, uc3, lc32, uc32);
	sigOW = 0;
	sigOB = 0;
	sigOBvsOW = 0;
	if nmiss(Estimate2, StdErr2) = 0 then do;
		z = Estimate2 - 1.96 * StdErr2;
		if z > 709 then lc2 = .;
		else if z < -745 then lc2 = 0;
		else lc2 = exp(z);
		z = Estimate2 + 1.96 * StdErr2;
		if z > 709 then uc2 = .;
		else if z < -745 then uc2 = 0;
		else uc2 = exp(z);
	end;
	if nmiss(Estimate3, StdErr3) = 0 then do;
		z = Estimate3 - 1.96 * StdErr3;
		if z > 709 then lc3 = .;
		else if z < -745 then lc3 = 0;
		else lc3 = exp(z);
		z = Estimate3 + 1.96 * StdErr3;
		if z > 709 then uc3 = .;
		else if z < -745 then uc3 = 0;
		else uc3 = exp(z);
	end;
	if nmiss(Estimate2, StdErr2, Estimate3, StdErr3) = 0 then do;
		diff32 = Estimate3 - Estimate2;
		if missing(StdErr32) then se32 = sqrt(StdErr2 ** 2 + StdErr3 ** 2);
		else se32 = StdErr32;
		z = diff32 - 1.96 * se32;
		if z > 709 then lc32 = .;
		else if z < -745 then lc32 = 0;
		else lc32 = exp(z);
		z = diff32 + 1.96 * se32;
		if z > 709 then uc32 = .;
		else if z < -745 then uc32 = 0;
		else uc32 = exp(z);
	end;
	if nmiss(lc2, uc2) = 0 then sigOW = (lc2 > 1) | (uc2 < 1);
	if nmiss(lc3, uc3) = 0 then sigOB = (lc3 > 1) | (uc3 < 1);
	if nmiss(lc32, uc32) = 0 then sigOBvsOW = (lc32 > 1) | (uc32 < 1);
	drop lc2 uc2 lc3 uc3 lc32 uc32 z diff32 se32;
run;

proc sort data = db_join;
	by order label base;
run;

proc sql noprint;
	select count(distinct(id)) into :n_ids trimmed
	from &impdb.
	where keep_ms1560;
quit;

ods listing close;
ods path sashelp.tmplmst(read) hchstyle.hchs_stp(read);
ods rtf file = "&homepath.\scripts\&job.\&job._Table&table_num._&sysdate..rtf" style = manuscrt bodytitle;
%let fs = 11pt;
%let fs_titles = 11pt;
%let rgt_mgn = 0.1in;

* SPLIT must not be '^' — same as ODS ESCAPECHAR so inline ^S={...} breaks and prints verbatim (headers showed crude style text);
proc report data = db_join split = '#'
	style(header) = [fontsize = &fs]
	style(column) = [fontsize = &fs];
	title j = center height = &fs font = 'times roman' bold
		"^S={leftmargin=&lf_margin rightmargin=&rgt_mgn}Table &table_num.. Maternal preconception socio-behavioral factors and child BMI category, HCHS/SOL FLOR Ancillary Study (n=%qtrim(&n_ids))";
	footnote1 j = left height = &fs_titles font = 'times roman'
		"^S={leftmargin=&lf_margin rightmargin=&rgt_mgn}Abbreviations: CI, confidence interval; FLOR, Family Lifestyle Outcomes Research; OR, odds ratios; PA, physical activity.";
	footnote2 j = left height = &fs_titles font = 'times roman'
		"^S={leftmargin=&lf_margin rightmargin=&rgt_mgn}Odds ratios and 95% confidence intervals from multinomial logistic regression models (Overweight vs Normal and Obese vs Normal) fit to multiply imputed data (10 imputations) and pooled using Rubin's rules. Obese vs Overweight odds ratios were derived from the corresponding log-odds contrast.";
	footnote3 j = left height = &fs_titles font = 'times roman'
		"^S={leftmargin=&lf_margin rightmargin=&rgt_mgn}Bold odds ratio (95% CI) indicates the confidence interval excludes 1.00 (two-sided nominal alpha = 0.05).";
	footnote5 j = left height = 10pt font = 'times roman'
		"{\line \line Job &job run by &prg using FLOR analytic file (HC338353b) on %sysfunc(today(), date9.) at %qtrim(%sysfunc(time(), timeampm.))}";
	column order label sigOW statsOW sigOB statsOB sigOBvsOW statsOBvsOW;
	define order / order order = internal group noprint;
	define label / display group 'Predictor' flow style(header) = [fontsize = &fs just = left]
		style(column) = [fontsize = &fs width = 2.8in cellwidth = 2.8in];
	define sigOW / display noprint;
	define statsOW / display 'Overweight vs Normal#OR (95% CI)'
		style(header) = [fontsize = &fs vjust = bottom just = right]
		style(column) = [fontsize = &fs vjust = bottom just = right cellwidth = 1.35in font_weight = medium];
	define sigOB / display noprint;
	define statsOB / display 'Obesity vs Normal#OR (95% CI)'
		style(header) = [fontsize = &fs vjust = bottom just = right]
		style(column) = [fontsize = &fs vjust = bottom just = right cellwidth = 1.35in font_weight = medium];
	define sigOBvsOW / display noprint;
	define statsOBvsOW / display 'Obesity vs Overweight#OR (95% CI)'
		style(header) = [fontsize = &fs vjust = bottom just = right]
		style(column) = [fontsize = &fs vjust = bottom just = right cellwidth = 1.35in font_weight = medium];
	compute statsOW;
		if sigOW = 1 & strip(statsOW) not in ('' '---') then call define(_col_, 'style', 'style=[font_weight=bold]');
	endcomp;
	compute statsOB;
		if sigOB = 1 & strip(statsOB) not in ('' '---') then call define(_col_, 'style', 'style=[font_weight=bold]');
	endcomp;
	compute statsOBvsOW;
		if sigOBvsOW = 1 & strip(statsOBvsOW) not in ('' '---') then call define(_col_, 'style', 'style=[font_weight=bold]');
	endcomp;
run;

ods rtf close;

proc printto;
run;
