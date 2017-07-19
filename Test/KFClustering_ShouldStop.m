%% Testing KFClustering using 2 group fme examples
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;

rng(1)                                       % control the randomness

%% Simulation data
m = 30;                                       % number of observations
t = (1:m)/m;
p = 1;                                        % # of fixed effects
q = 1;                                        % # of random effects

nClusters = 2;

% group 1:
n1 = 50;                                      % # of subjects
sigma_e1 = 1;                                 % variance of white noise
d1 = 2*(p+n1*q);                              % dimension of states
realFixedEffect1 = 5*sin(2*pi*t);             % p-by-m
realRandomEffect1 = randn(n1,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];                           
Y1 = repmat(realFixedEffect1, [n1,1]) + realRandomEffect1 ... 
    + sqrt(sigma_e1)*randn(n1,m);

% group 2:
n2 = 50;                                      % # of subjects
sigma_e2 = 2;                                 % variance of white noise
d2 = 2*(p+n2*q);                              % dimension of states
realFixedEffect2 = 7*sin(2*pi*t);             % p-by-m
realRandomEffect2 = randn(n2,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
Y2 = repmat(realFixedEffect2, [n2,1]) + realRandomEffect2 ... 
    + sqrt(sigma_e2)*randn(n2,m);


dataset = [Y1; Y2];

realClusterIDs = [ones(n1,1); 2*ones(n2,1)];

plot(t, dataset');

%% kmeans

ClusterIDs_kmeans = kmeans(dataset, nClusters);

%% KFClustering and ShouldStop

fixedArray = ones(1,p);
randomArray = ones(1,q);
MAX_LOOP = 100;

tic
[ ClusterIDs_KF, ClusterMembers, Theta, switchHistory] = ...
    KFClustering(dataset, t, nClusters, ...
                fixedArray, randomArray, MAX_LOOP);
toc

plot(switchHistory);


                 


