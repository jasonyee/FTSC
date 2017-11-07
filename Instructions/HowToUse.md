The general function is in "C:\Users\jialinyi\Documents\MATLAB\FTSC\Clustering":

`SSMBuiltInClustering` function

As for the process to produce the existing workflow, take `gupisub` and `nCluster=3` as an example, remember to change the variables before running each program, and change number of clusters if needed.
Note that all the names are case-sensitive, so DO NOT change.

# Create folders

*  Create a folder under "Y:\Users\Jialin Yi\data\imputation", named as `gupisub`
*  Create a folder under "Y:\Users\Jialin Yi\output", named as `GUPISUB`
*  Create a folder under "Y:\Users\Jialin Yi\output\GUPISUB", named as `Wald`
*  Create a folder under "Y:\Users\Jialin Yi\output\GUPISUB\Wald", named as `3C`
*  Create a folder under "Y:\Users\Jialin Yi\data", named as `GUBISUB`


# Data processing

*  Get raw data in to "Y:\Users\Jialin Yi\data\imputation\raw.csv"
*  SAS imputation program : run "~\FTSC\DataProcessing\imputation.sas"
*  Move results into "Y:\Users\Jialin Yi\data\imputation\gupisub"
*  Get dif, nomiss variables: run "~\FTSC\DataProcessing\yvar.R"
*  Convert csv to sas7bdat file: "~\FTSC\DataProcessing\csv2sas7bdat.sas"


# Wald hierarchical clustering

*  SAS clustering program: "~\FTSC\DataProcessing\WaldClustering.sas"
*  Move results into "Y:\Users\Jialin Yi\output\GUPISUB\Wald\3C"


# Data transfer

* Wald2MATLAB.R: "~\FTSC\DataProcessing\Wald2MATLAB.R"


# Functional Clustering

"xxx" for symq5/symq6/painsev/urinsev/...

## Functional Clustering
"FTSC\Real\xxx\xxx.m"

## Demo program 
spaghetti plot, switches, subject fit: "FTSC\Real\xxx\demo_xxx.m"