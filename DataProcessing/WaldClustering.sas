/**Modify when variable changes:
	1. libname outdt
	2. libname dtsrc
	3. macro variable yvar
	4. html path
**/

***Specify the variable to analyze;
%let yvar = gupisub;
%let bigyvar = %str(GUPISUB);
%let smallyvar = %str(gupisub);


libname outdt "Y:\Users\Jialin Yi\output\&bigyvar.\Wald";
libname dtsrc "Y:\Users\Jialin Yi\data\imputation\&smallyvar.";


/*************** 1. Import data ***************/
data yvar;
	set dtsrc.&yvar.;
	rename pid = subid;
run;

data yvar;
	retain pid;
	set yvar;
	by subid;
	if first.subid then pid+1;
	pids = put(pid, 8.);
run;

data yvar_dif_nomiss;
	set yvar (keep= pid pids visit &yvar._dif_nomiss);
	rename &yvar._dif_nomiss = y;
run;



/*************** 2. Distance matrix ***************/
proc transpose data = yvar_dif_nomiss out=tspred prefix = pred_;
	by pid pids;
	id visit;
	var y;
run;

proc Distance data = tspred out=outib absent=0 method=DGOWER;
	title 'Distance';
	var INTERVAL (pred_4 pred_5
					pred_6 pred_7 pred_8 pred_9 pred_10
					pred_11 pred_12 pred_13 pred_14 pred_15
					pred_16 pred_17 pred_18 pred_19 pred_20
					pred_21 pred_22 pred_23 pred_24 pred_25);
	id pids;
run;


/*************** 3. Wald clustering nClusters=3 ***************/
ods html body="&yvar._waldsum.html" style=HTMLBlue
	path="Y:\Users\Jialin Yi\output\&bigyvar.\Wald";

proc cluster data=outib
	method=ward
	plots=dendrogram(height=rsq)
	plots=(ccc pst2 psf)
	pseudo
	k=30
	outtree=tree;
	id pids;
run;

proc tree data=tree n=3 out=ntree;
	id pids;
run;

proc sort data=ntree;
	by pids;
run;

proc freq data=ntree;
	table cluster/nocum missing;
run;

ods html close;

/*************** 4. Merge into raw dif data ***************/

proc sql;
	create table yvar_cluster as
		select distinct a.*, b.cluster from 
			yvar a left join ntree b
			on a.pids = b.pids
			order by pid, visit;
quit ;


data outdt.&yvar._wald;
	set yvar_cluster;
	drop pids;
run;
