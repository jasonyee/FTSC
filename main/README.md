# Workflow for using FTSC to analyze new data set

## I. Functional Clustering

1. Use `FTSC` function. 
2. Specify the path for storing the results.


## II. Cluster Plot

1. Use `ClusterPlot` function.
2. Specify the `Options, yvar, YVAR_path, YVAR_plot` to load in the MAT-file.


## III. Get ProgressIDS

`ProgressIDs` are improved-0, stable-1, worse-2.

1. Specify the `cluster_id_progress` from the Cluster Plot (use your eyes!)

`cluster_id_progress = [<improve_id>, <stable_id>, <worse_id>]`

2. Use `ProgressID` function to save `ProgressIDs` to the MAT file.

Specify the `Options, yvar, YVAR_path, YVAR_plot` to load in the MAT-file.


## IV. Demostration

1. Specify the `clusterOptions, yvar, YVAR_path, YVAR_plot` to load in the MAT-file.

2. Use `demo_clustering` function to show:
   (1). Running time;
   (2). Switch plot;
   (3). Spaghetti plot for group-average fit
   (4). Subject-level fit

