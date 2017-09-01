%% Paper simulation data, built-in, cubic spline(F), sin prior(R)
%  Adding the following folders to the path:
%   -FTSC2

%% Clear
clear;
clc;

nClusters = 3;


%% Loading data
load('C:\Users\jialinyi\Documents\MATLAB\FTSC\Simulation\data\simu_data_miss.mat');

dataset = MissingDt;

IniClusterIDs = WaldClusterID;

% get time points
[~, m] = size(dataset);
t = (1:m)/m;

plot(dataset');

RealClusterIDs = [ones(50,1); 2*ones(50,1); 3*ones(50,1)];
RealClusterMembers = ClusteringMembers(nClusters, RealClusterIDs);

%% Clustering setting
MAX_LOOP = 20;
logpara0 = [5;10;10;0;0];

%% Clustering starts
tic
[ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP] =...
    SSMBuiltInClustering(dataset, nClusters, IniClusterIDs, logpara0, MAX_LOOP);
clustertime = toc;


%% Convergence of algorithm

plot(SwitchHistory)
title('Switches in each iteration')



