# Simulations setting and the corresponding parameters for `FunHDDC`

number of clusters $K=3$.
number of subjects in each cluster $n=100$

## low noise: 

| $\sigma_2 = 1$       | nbasis   | threshold | ini.vector |
| ------------- |:-------------:| :-------------:|:-------------:|
| $R = [100, 100, 100]$      | 7 | 0.8| vector
| $R = [200, 100, 100]$      |   10    | 0.2| kmeans|
| $R = [200, 200, 200]$ |   8    | 0.2| kmeans|


## high noise: 

| $\sigma_2 = 2$       | nbasis     | threshold | ini.vector|
| ------------- |:-------------:|:-------------:|:-------------:|
| $R = [100, 100, 100]$      |  7 | 0.8 | vector |
| $R = [200, 100, 100]$      |   9    | 0.4 | kmeans|
| $R = [200, 200, 200]$ |   11    | 0.2| kmeans|