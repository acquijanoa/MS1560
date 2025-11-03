
PROC FORMAT;
	VALUE BKGRD1_C7NOMISS_FMT
	    0 = "DOMINICAN"
	    1 = "C_AMERICAN"
	    2 = "CUBAN"
	    3 = "MEXICAN"
	    4 = "P_RICAN"
	    5 = "MORE THAN ONE"
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
	VALUE N_HC_FMT
		0 = "NO" 
		1 = "YES";
	VALUE INCOME_C2_FMT
		1 = "<30"
		2 = ">30";
	VALUE YRSUS_C3_FMT
		1 = "<10_Years"
		2 = "10+_Years" 
		3 = "US_BORN";
	VALUE EMPLOYEDYN_FMT
		0 = "NOT_EMPLOYED" 
		1 = "EMPLOYED" 
		;
	VALUE ALCOHOL_USE_FMT
		1 = "NEVER"
		2 = "FORMER"
		3 = "CURRENT"
		;
	VALUE $STAT
		"MEAN" = 'M/%' 
		"STDERR" = '(SE)';
	VALUE PV
		1 = '***'
		2 = '**'
		3 = '*'
		4 = "."
		5 = ' '
		. = ' ';
	VALUE YN_FMT
		0 = "NO"
		1 = "YES";
	PICTURE BLANKDOT (DEFAULT=8)
    	. = '        '     
    	OTHER = '009.99'   /* 8.2 numeric style (adjust as needed) */
  	;
	VALUE REFNUM 
		98 = 'Ref.'
		99 = ' '
		. = ' '
		OTHER = [8.2];
	VALUE PAREN (ROUND)
		99 = ' '
		. = ' '
		OTHER = [negparen.2]; 
RUN;
