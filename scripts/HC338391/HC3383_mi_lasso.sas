/*************************************************************************************
 Program: MI_lasso macro.sas           
 
 NOTE: This SAS program includes:
 1) The SAS macro "%MI_lasso(datain=,lambda=,maxiter=,eps=)" to implement the MI-lasso 
    variable selection method. The &datain contains a data set that has p+2 columns, 
    with the first p columns being the covariates X1-Xp, the (p+1)th column being the 
    outcome Y, and the (p+1)th column being the imputation indication denoting which
    imputation the row of observation belongs to. The imputation variable must be coded
    as "imputation" and can have take integer values from 1 to D. The &datain is in the
    long format. That is, all the D imputed datasets are stacked together. The &lambda is 
    the tuning parameter. The "maxiter" is the maximum number of iterations we want to
    in the MI-lasso model estimation to achieve convergency. The "&eps" is the largest
    allowed difference between the estimated coefficients in two consecutive iterations. 
 2) An example on how to use the "%MI_lasso" SAS macro.

 Reference:
 Chen, Q. & Wang, S. (2013). "Variable selection for multiply-imputed data with
 application to dioxin exposure study," Statistics in Medicine, 32(21): 3646-3659.

 Retrieved from:
	https://www.columbia.edu/~qc2138/Downloads/software/MI_lasso%20macro.sas

****************************************************************************************/


%macro MI_lasso(datain=,lambda=,maxiter=,eps=);

proc iml;
use &datain; read all into mydata; 
use &datain(where=(imputation=1)); read all into mydata1;

* Part1: parameters;
n=nrow(mydata1);
p=ncol(mydata)-2;
D=mydata[,p+2][<>]; 
lambda=&lambda; 
maxiter=&maxiter; 
eps = &eps; 

* Part 2: standardization and OLS estimation;
X=mydata[,1:p]; 
Y=mydata[,p+1]; 
MeanX=J(D,p,0); 
NormX=J(D,p,0); 
MeanY=J(D,1,0); 
b_ols=J(D,p,0);

do i=1 to D; 
  Xi=X[((i-1)*n+1):(i*n),];
  Mean_Xi=Xi[:,];
  Xi=Xi-repeat(Mean_Xi,n);
  MeanX[i,]=Mean_Xi;
  Norm_Xi=sqrt((Xi##2)[+,]);
  Xi=Xi/repeat(Norm_Xi,n);
  NormX[i,]=Norm_Xi;

  Yi=Y[((i-1)*n+1):(i*n),];
  Mean_Yi=Yi[:,];
  Yi=Yi-repeat(Mean_Yi,n);
  MeanY[i,]=Mean_Yi;

  b_ols[i,]=t(inv(t(Xi)*Xi)*t(Xi)*Yi);

  X[((i-1)*n+1):i*n,]=Xi; 
  Y[((i-1)*n+1):i*n,]=Yi;
end;

* Part 3: Estimate beta_dj in Equation (4);
iter=0; 
dif=1;
c=J(p,1,1);
b=J(p,D,0);
do while (iter<=maxiter & dif>=eps);     
  iter=iter+1;
  b_old=b;
  *update beta_d by ridge regression;
  do i=1 to D;
    Xi=X[((i-1)*n+1):i*n,];
	Yi=Y[((i-1)*n+1):(i*n),];
    XtX=t(Xi)*Xi+diag(lambda/c);
    XtY=t(Xi)*Yi;
    b[,i]=inv(XtX)*XtY;
  end;
  *update c;
  c=sqrt((b##2)[,+]);
  do j=1 to p;
    if c[j,]<sqrt(D)*10**(-10) then c[j,]=sqrt(D)*10**(-10); 
  end;
  dif=abs(b-b_old)[,<>][<>,]; 
end; 

do j=1 to p;
     if(b##2)[j,+]<10**(-8) then b[j,]=0;
end;

*Part 4:calculate BIC;
sse=J(1,D,0);
do i=1 to D;
  Xi=X[((i-1)*n+1):i*n,];
  Yi=Y[((i-1)*n+1):i*n,]; 
  sse[,i]=((Yi-Xi*b[,i])##2)[:];
end; 

df=0;
do j=1 to p;
  norm1=sqrt(b[j,][##]);
  norm2=sqrt(b_ols[,j][##]);
  if abs(b[j,1])>0 then df=df+1+(D-1)*norm1/norm2;
end;

BIC=log(sse[:])+log(D*n)*df/(D*n);


* Part 5:transform beta back to original scale;
bscaled=b;
b0=J(1,D,0);
coefficients=J(p+1,D,0);
do i=1 to D;
  b[,i]=b[,i]/t(NormX[i,]);
  b0[,i]=MeanY[i,]-MeanX[i,]*b[,i];
  coefficients[1,i]=b0[,i];
  coefficients[(2:(p+1)),i]=b[,i];
end;


* Part 6:output the selected variables;
varsel=J(1,p,0);
do j=1 to p;
    if b[j,1]=0 then varsel[,j]=0; else varsel[,j]=1;
end;

* output results;
BIC_lam=J(1,2,0);
BIC_lam[1]=&lambda;
BIC_lam[2]=BIC; 
create BIC_lam from BIC_lam;
append from BIC_lam;
create coefficients from coefficients;
append from coefficients;
create varsel from varsel;
append from varsel;

quit;

%mend MI_lasso;


/******** An example on the use of the "MI.lasso" function *********/


/*
*Input a list of tuning parameter lambda;
proc iml;
a = do(-1, 4, 0.05);
lamvec = t(2**(2*a)/2);
create lamvec from lamvec;
append from lamvec;
quit;
proc sql noprint;                   
select count(*) into :nlambda from lamvec;
quit; 
%put &nlambda;

*Select tuning parameter with the smallest BIC from the dataset "test";
%macro PickLambda(lamvec);
data bicvec; set _NULL_; run;
%do i=1 %to &nlambda;
data _NULL_; set &lamvec;
if _N_=&i then call symput('lambda',COL1); 
run;
%MI_lasso(datain=test,lambda=&lambda,maxiter=200,eps=10**(-6));
data bicvec; set bicvec bic_lam; run;
%end;
%mend PickLambda;
%PickLambda(lamvec);

proc sort data=bicvec; by COL2; run;
data _NULL_; set bicvec;
if _N_=1 then call symput('lambda',COL1);
run;
%put &lambda;

*Fit the model with the optimal lambda;
%MI_lasso(datain=test,lambda=&lambda,maxiter=200,eps=10**(-6));
proc print data=coefficients; run;
proc print data=varsel; run;

*/





