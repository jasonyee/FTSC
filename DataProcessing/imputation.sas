libname outdt "Y:/Users/Jialin Yi/data/imputation";

%let yvar = sf12_mcs;

proc import datafile = 'Y:/Users/Jialin Yi/data/imputation/raw.csv'
	out = raw
	dbms = csv
	;
run;


data yvar_raw;
	set raw (keep = pid vnum &yvar);
run;


data yvar_raw_cubic;
	set yvar_raw;
	month = (vnum-1)/2;
	month2 = month * month;
	month3 = month * month2;
run;


ods html body="&yvar..html" 
	style=HTMLBlue
	path= "Y:\Users\Jialin Yi\data\imputation";

proc mixed data=yvar_raw_cubic method=ML COVTEST;
	class pid;
	model &yvar =month month2 /s outp=blup ;
	random intercept month month2  /sub=pid type=un G GCORR  ;
run;

ods html close;

proc sort data=blup out=spred;
	by pid vnum;
run;

data outdt.&yvar._pred;
	set spred;
run;
