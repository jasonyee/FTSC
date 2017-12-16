%let dataset = %str(sf12_pcs);


libname outdt "Y:/Users/Jialin Yi/data/imputation/&dataset.";


proc import datafile = "Y:/Users/Jialin Yi/data/imputation/&dataset./&dataset..csv"
	out = data_pre
	dbms = CSV
	;
run;

/*proc print data=data_pre;
run;
*/

data mydata;
	set data_pre;
	drop var1;
run;


data outdt.&dataset.;
	set mydata;
run;

