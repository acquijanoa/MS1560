
PROC FORMAT;
	VALUE BKGRD1_C7NOMISS_FMT
	    0 = "DOMINICAN"
	    1 = "C_AMERICAN"
	    2 = "CUBAN"
	    3 = "MEXICAN"
	    4 = "P_RICAN"
	    5 = "SOUTH"
		6 = "BK_OTHER";
	VALUE PV
		1 = '***'
		2 = '**'
		3 = '*'
		4 = ' '
		5 = '--'
		. = '---';
	VALUE CENTERNUM_FMT
		1 = "BRONX"
		2 = "CHICAGO"
		3 = "MIAMI"
		4 = "SAN DIEGO";
	VALUE LANG_PREF_FMT
		1 = "SPANISH"
		2 = "ENGLISH";
	VALUE MARITAL_STATUS_FMT
		1 = "SINGLE"
		2 = "COHABITING"
		3 = "SEPARATED";
	VALUE EDUCATION_C3_FMT
		1 = "N_HIGHSCHOOL_GED"
		2 = "AT_MOST_HIGHSCHOOL_GED"
		3 = "G_HIGHSCHOOL";
	VALUE n_hc_fmt
		0 = "NO" 
		1 = "YES";
	VALUE income_c2_fmt
		1 = "<30"
		2 = ">30";
	VALUE yrsus_c3_fmt		
		1 = "<10_Years"
		2 = "10+_Years" 
		3 = "US_BORN";
	VALUE employedyn_fmt
		0 = "NOT_EMPLOYED" 
		1 = "EMPLOYED" 
		;
	VALUE alcohol_use_fmt
		1 = "NEVER"
		2 = "FORMER"
		3 = "CURRENT"
		;
	value cigarette_use_fmt
		1 = "NEVER"
		2 = "FORMER"
		3 = "CURRENT"
		
		;
	value slpdur_lt8hrs_fmt
		0 = ">=8_hours"
		1 = "<8_hours"
		;
	value hei2010_c3_fmt
		1 = "LOW"
		2 = "MEDIUM"
		3 = "HIGH";
	value bmipct_c3_fmt
		1 = "Normal"
		2 = "Overweight"
		3 = "Obese"
	;
	value cesd10_fmt
	   LOW-<10 = "NODEPRE"
	   10- HIGH = "DEPRE"
	;
	value stai10_fmt
	   LOW-<20 = "NOANX"
	   20- HIGH = "ANX"
	;
	VALUE $STAT
		"MEAN" = 'M/%' 
		"STDERR" = '(SE)';
	VALUE PV
		1 = '***'
		2 = '**'
		3 = '*'
		4 = " "
		5 = ' '
		. = ' ';
	VALUE YN_FMT
		0 = "NO"
		1 = "YES";
	VALUE BMIPCT_C2_FMT
		0 = 'NORMAL'
		1 = 'OVERWEIGHT OR OBESE'
	;
	PICTURE BLANKDOT (DEFAULT=8)
    	. = '        '     
    	OTHER = '009.99'   /* 8.2 numeric style (adjust as needed) */
  	;
	VALUE REFNUM 
		98 = 'Ref.'
		99 = ' '
		. = ' '
		OTHER = [8.2];
	/* SE stored negative for NEGPAREN; negparen.2 default w is too narrow for
	   values >=10 (e.g. (10.25) needs 8+ characters) */
	VALUE PAREN (ROUND)
		99 = ' '
		. = ' '
		OTHER = [negparen12.2];
 	PICTURE pct_blank (round)
        . = ' '
        low-high = '009.99%'; 
	VALUE AME_fmt
		. = ' '
		other = [8.2];
RUN;
