# Functional Time Series Clustering

Functional Time Series Clustering (FTSC) is an *unsurpervised* learning algorithm for *time series* data.
Unlike kmeans, PCA and many other clustering algorithms, FTSC could handle the data with *missing values* in a most natural way.

In real-world data set, missing values are inevitable and also imply important information.
Traditional way to handle missing values like data imputation will sometimes destroy the information conveyed by missing values.

In the case of missing data, FTSC outperforms the traditional workflow, like imputing-data-first-then-using-kmeans.

This is a summer research project I worked on at the biostatistics department in Perelman school of medicine, University of Pennsylvania.

I am very fortunate to be co-advised by Prof. [J. Richard Landis](https://scholar.google.com/citations?user=WDSnxagAAAAJ&hl=en) and Prof. [Wensheng Guo](https://scholar.google.com/citations?user=WYCrBGUAAAAJ&hl=en).
Without their detailed guidance and caring support, I cannot finish the whole project.

# Demo

## Simulation

3 groups of data with different time series structure, each has 50 subjects.

![Figure 1 simulated data](https://github.com/jasonyee/FTSC/blob/master/demo/simulation/raw.png)


## Performance

| kmeans + imputation | Cluster1 | Cluster2 | Cluster3 |
|:-------------------:|----------|----------|----------|
| True Group 1        | 48       | 2        | 0        |
| True Group 2        | 0        | 1        | 49       |
| True Group 3        | 6        | 44       | 0        |

|     FTSC     | Cluster1 | Cluster2 | Cluster3 |
|:------------:|----------|----------|----------|
| True Group 1 | 49       | 1        | 0        |
| True Group 2 | 0        | 0        | 50       |
| True Group 3 | 2        | 48       | 0        |

The visualization of the clustering results from FTSC is

![Figure 2 FTSC for simulated data](https://github.com/jasonyee/FTSC/blob/master/demo/simulation/spaghetti.png)


## Model selection

The number of clusters is determined by data itself, through an estimator of Kullback-Leibler divergence.

The optimal number of clusters minimized the Kullback-Leibler divergence.

![Figure 3 KL for simulated data](https://github.com/jasonyee/FTSC/blob/master/demo/simulation/kl_curve.png)

## Real data: SYM-Q5

Symptom and Health Care Utilization Questionnaire, denoted as SYM-Q5, is a self-rated
total severity score of overall urologic or pelvic pain symptoms.
An increasing SYM-Q5 score indicates that the overall urologiv or pelvic symptoms are worsening.

Clustering the patients through their SYM-Q5 scores over a period time can help hospital to evaluate the effectness of treatment and concentrate resources on the patients who get worse.

We use FTSC on the SYM-Q5 data from 397 patients with number of clusters equal to 3, the results are:

![Figure 4 FTSC for SYM-Q5 data](https://github.com/jasonyee/FTSC/blob/master/demo/symq5/spaghetti.png)

*  109 (27.5%) getting better (improving, symptom change scores decrease over time); 
*  126 (31.7%) remaining stable (symptom change scores vary around 0); 
*  162 (40.8%) worsening (symptom change scores increase over time).

# Features of FTSC code

This is the version with:

*  numerical stable filtering and smoothing algorithm for time-variant state space model
*  functional mixed effect model for periodic data
*  allow missing data
*  functional clustering on time series data
*  choosing optimal number of clusters through estimated Kullback-Leibler divergence