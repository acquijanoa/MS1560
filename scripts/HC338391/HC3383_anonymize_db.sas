*------------------------------------;
*-- DATASET ANONYMIZATION MACRO ---;
*------------------------------------;

/*
  Macro: ANONYMIZE_DB

  Description:
  This macro performs the anonymization of a dataset by merging it with a master
  encryption file and retaining only the necessary variables. It then sorts the
  resulting dataset by a specified identifier.

  Parameters:
  - DATA: Input dataset to be anonymized.
  - OUT: Output dataset containing the anonymized information.

  Usage:
  %ANONYMIZE_DB(INPUT_DATASET, OUTPUT_DATASET);

  Example:
  %ANONYMIZE_DB(MyData, AnonymizedData);
*/
LIBNAME ENCRP "J:\HCHS\SC\SASDATA\Encrypted_IDs";
LIBNAME TRANSID 'J:\HCHS\SC\SASDATA\Transfer_IDS';

%MACRO ANONYMIZE_DB(DATA, OUT);
	/* SORTING THE TRANSFER IDs DATASET*/
	PROC SORT DATA=TRANSID.transfer_ids out=transfer_ids;
  		BY SUBJECTID;
	RUN;

	/*
	DATA ENCRYPT(DROP=TRANSFERID);
		MERGE TRANSFER_IDS(KEEP=SUBJECTID TRANSFERID) 
			ENCRP.MASTER_ENCRYPTION_FILE_INV3V1(KEEP=SUBJID ID RENAME=(SUBJID=SUBJECTID));
		BY SUBJECTID;	

		IF ^MISSING(TRANSFERID) AND SUBJECTID NOT IN ('M7146287','M7008139') THEN SUBJECTID = TRANSFERID;
	RUN;
	*/
	DATA TRANSFER0(DROP=SUBJECTID);
		MERGE TRANSFER_IDS(KEEP=SUBJECTID TRANSFERID IN=A) 
			ENCRP.MASTER_ENCRYPTION_FILE_INV3V1(KEEP=SUBJID ID RENAME=(SUBJID=SUBJECTID));
		BY SUBJECTID;	
		IF A;
	RUN;

	DATA ENCRYPTO;
		SET ENCRP.MASTER_ENCRYPTION_FILE_INV3V1(KEEP=SUBJID ID RENAME=(SUBJID=SUBJECTID))
		TRANSFER0(KEEP=TRANSFERID ID RENAME=(TRANSFERID=SUBJECTID));
	RUN;			

	PROC SORT DATA=ENCRYPTO OUT=ENCRYPT;
       BY SUBJECTID;
    RUN; 

  	/* Step 1: Create a temporary dataset named DATASET by copying the input dataset */
  	DATA DATASET;
   	 	SET &DATA;
  	RUN;

  	/* Step 2: Merge the temporary dataset with the master encryption file */
  	DATA &OUT;
    	MERGE ENCRYPT(KEEP=SUBJECTID ID)
          DATASET(IN=A);
    	BY SUBJECTID;
	/* Uncomment the line below if SUBJECTID needs to be dropped */
    	DROP SUBJECTID;
    	IF A;
  	RUN;

  /* Step 3: Sort the output dataset by the specified identifier */
  PROC SORT DATA=&OUT OUT=&OUT;
    BY ID;
  RUN;

%MEND ANONYMIZE_DB;
