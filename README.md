# FTSC
Functional Time Series Clustering

This is a summer project I am working on at the biostatistics department in Perelman school of medicine, University of Pennsylvania.

I am very fortunate to be co-advised by Prof. Richard Landis and Prof. Wensheng Guo.

The aim of the project is to classify the time series data collected from the patients to make statistical inference.

# Features

This is the version with:

*  numerical stable filtering and smoothing algorithm for time-variant state space model
*  functional mixed effect model for periodic data
*  allow missing data
*  functional clustering on time series data
*  choosing optimal number of clusters

# Demo

## Simulatated data

![Figure 1 choose the number of clusters](https://github.com/jasonyee/FTSC/blob/master/demo/simulation/raw.png)

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
