%% Testing DSSClustering and kmeans using 2 group fme examples
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
n1 = 20;                                      % # of subjects
sigma_e1 = 1;                                 % variance of white noise
d1 = 2*(p+n1*q);                              % dimension of states
realFixedEffect1 = 5*sin(2*pi*t);             % p-by-m
realRandomEffect1 = randn(n1,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];                           
Y1 = repmat(realFixedEffect1, [n1,1]) + realRandomEffect1 ... 
    + sqrt(sigma_e1)*randn(n1,m);

% group 2:
n2 = 20;                                      % # of subjects
sigma_e2 = 1;                                 % variance of white noise
d2 = 2*(p+n2*q);                              % dimension of states
realFixedEffect2 = 7*sin(2*pi*t);             % p-by-m
realRandomEffect2 = randn(n2,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
Y2 = repmat(realFixedEffect2, [n2,1]) + realRandomEffect2 ... 
    + sqrt(sigma_e2)*randn(n2,m);


dataset = [Y1; Y2];

realClusterIDs = [ones(n1,1); 2*ones(n2,1)];

ClusterMembers_real = cell(1, nClusters);
for k=1:nClusters
    ClusterMembers_real{k} = find(realClusterIDs == k);
end
ClusterData_real = ClusteringData(dataset, ClusterMembers_real);
ClusteringVisual(dataset, ClusterData_real, t);

%% kmeans: fitting
ClusterIDs_kmeans = kmeans(dataset, nClusters);

%% kmeans: visualization
ClusterMembers_kmeans = cell(1, nClusters);
for k = 1:nClusters
    ClusterMembers_kmeans{k} = find(ClusterIDs_kmeans == k);
end
ClusterData_kmeans = ClusteringData(dataset, ClusterMembers_kmeans);
ClusteringVisual(dataset, ClusterData_kmeans, t);

%% kmeans: sensitivity analysis
SensRate1 = SensitivityAnalysis(ClusterMembers_real, ClusterMembers_kmeans, [1, 2]);
SensRate2 = SensitivityAnalysis(ClusterMembers_real, ClusterMembers_kmeans, [2, 1]);

fprintf('If the real cluster 1 corresponds to the kmeans-output cluster 1, then sensitivity rate is [%f, %f]\n', SensRate1);
fprintf('If the real cluster 1 corresponds to the kmeans-output cluster 2, then sensitivity rate is [%f, %f]\n', SensRate2);


%% DSSClustering: fitting

fixedArray = ones(1,p);
randomArray = ones(1,q);
MAX_LOOP = 100;

tic
[ ClusterIDs_DSS, ClusterMembers_DSS, Theta, switchHistory] = ...
    DSSClustering(dataset, t, nClusters, ...
                fixedArray, randomArray, MAX_LOOP);
toc

%%  DSSClustering: iterations
figure;
plot(switchHistory);
title('DSSClustering iteration');
xlabel('iterative steps');
ylabel('switches');

%% DSSClustering: visualization
ClusterData_DSS = ClusteringData(dataset, ClusterMembers_DSS);
ClusteringVisual(dataset, ClusterData_DSS, t);

%% DSSClustering: sensitivity analysis

SensRate3 = SensitivityAnalysis(ClusterMembers_real, ClusterMembers_DSS, [1, 2]);
SensRate4 = SensitivityAnalysis(ClusterMembers_real, ClusterMembers_DSS, [2, 1]);

fprintf('If the real cluster 1 corresponds to the dss-output cluster 1, then sensitivity rate is [%f, %f]\n', SensRate3);
fprintf('If the real cluster 1 corresponds to the dss-output cluster 2, then sensitivity rate is [%f, %f]\n', SensRate4);

                 


