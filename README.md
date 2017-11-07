# Functional Time Series Clustering

Functional Time Series Clustering (*FTSC*) is an nonparametric clustering algorithm for time series data.
Unlike kmeans, PCA and many other clustering algorithms, FTSC could handle the data with *missing values* in a most natural way.
Besides,  *FTSC* is very flexible and works well even when groups in dataset have heterogeneous structure as *FTSC* takes into consideration the with-in group variability.

This is a summer research project I participate in at Department of Biostatistics, Epidemiology and Informatics in Perelman school of medicine, University of Pennsylvania.

I am very fortunate to be co-advised by Prof. [J. Richard Landis](https://scholar.google.com/citations?user=WDSnxagAAAAJ&hl=en) and Prof. [Wensheng Guo](https://scholar.google.com/citations?user=WYCrBGUAAAAJ&hl=en).
Without their detailed guidance and caring support, I wouldn't have finished the whole project.

# Demo

## Performance

Here is the performance comparison about the classification rate of FTSC, FunHDDC and K-means.

[FunHDDC](https://cran.r-project.org/web/packages/funHDDC/index.html) is a popular model-based clustering method.

![Figure 1 Classification rate boxplot](https://github.com/jasonyee/FTSC/blob/master/demo/simulation/Heter_panel_crate.png)

## Simulation

3 groups of data with different time series structure, each has 50 subjects.

![Figure 2 Simulated data (sin curves)](https://github.com/jasonyee/FTSC/blob/master/demo/simulation/spaghetti_Keq1.png)

The visualization of the clustering results from FTSC is

![Figure 3 FTSC Recovery plot for simulated data](https://github.com/jasonyee/FTSC/blob/master/demo/simulation/Spaghetti.png)


## Real data: SYM-Q5

Symptom and Health Care Utilization Questionnaire, denoted as SYM-Q5, is a self-rated
total severity score of overall urologic or pelvic pain symptoms.
An increasing SYM-Q5 score indicates that the overall urologiv or pelvic symptoms are worsening.

Clustering the patients through their SYM-Q5 scores over a period time can help hospital to evaluate the effectness of treatment and concentrate resources on the patients who get worse.

We use FTSC on the SYM-Q5 data from 397 patients with number of clusters equal to 3, the results are:

![Figure 5 FTSC for SYM-Q5 data](https://github.com/jasonyee/FTSC/blob/master/demo/symq5/spaghetti.jpg)

*  110 (27.5%) getting better (improving, symptom change scores decrease over time); 
*  126 (31.7%) remaining stable (symptom change scores vary around 0); 
*  161 (40.8%) worsening (symptom change scores increase over time).

# Features of FTSC code

This is the version with:

*  numerical stable filtering and smoothing algorithm for time-variant state space model
*  functional mixed effect model for periodic data
*  allow missing data
*  functional clustering on time series data
*  choosing optimal number of clusters through estimated Kullback-Leibler divergence