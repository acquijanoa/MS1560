/*
	
	Program: HC3383_process_imputed.sas

	Programmer: Alvaro Quijano

	Description: Process beta estimates in the imputed datasets

	Date: 22may25
	 
*/

%macro process_imputed(in_db=, out_db=, model=);

	* Reshape the dataset to include effect names;
	data &in_db.;
	    set &in_db.;
	    length EffectName $50;
	    if missing(Level1) then EffectName = Parameter;
	    else EffectName = catx('_', Parameter, Level1);
	run;

	* Sort the dataset by effect name;
	proc sort data = &in_db.; by Effectname; run;

	* Combine estimates in the imputated dataset using Rubin method in MiAnalize;
	ods output ParameterEstimates = &out_db._p;
	proc mianalyze data=&in_db.;
	    by EffectName;
	    modeleffects Estimate;
	    stderr StdErr;
	run; 
	ods output close;

	data &out_db.;
	 	set &out_db._p(keep=EffectName estimate StdErr Probt 
						rename=(EffectName=variable));
		model = "Model &model.";
		%labels;
		if variable not in ('Scale','Intercept');
	run;

%mend process_imputed;
