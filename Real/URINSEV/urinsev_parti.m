%% Urinary severity data, built-in, cubic spline(F), sin prior(R)
%  Adding the following folders to the path:
%   -FTSC
% this program runs on the partitioned 2 period data set

%% Clear
clear;
clc;

%% Data I/O

path_data = 'Y:\Users\Jialin Yi\data\URINSEV\';

path_result = 'Y:\Users\Jialin Yi\output\URINSEV\Partition\';

%% Clustering setting
nClusters = 3;
MAX_LOOP = 20;
logpara0 = [1;10;6;-5;0];

%% First part of the partition data: Week 4-24
% load data
load(strcat(path_data, 'urinsev_dif_',num2str(nClusters),'C.mat'));
dataset = urinsev_dif(:,1:12);
IniClusterIDs = WaldClusterID;

% get time points
[~, m] = size(dataset);
t = (1:m)/m;

% clustering starts
tic;
[ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
    SSMBuiltInClustering(dataset, nClusters, IniClusterIDs, logpara0, MAX_LOOP);
clustertime = toc;

% convergence of algorithm
subplot(2, 5, nClusters);
plot(SwitchHistory)
title(strcat('Switches when', {' '},...
            'URINSEV', {', '}, ...
            'nClusters=', num2str(nClusters)));

% save result
save(strcat(path_result, 'URINSEV_dif_F_',num2str(nClusters),'C.mat'));

ProgressInfo = ['URINSEV ', ...
    ': nClusters = ', num2str(nClusters), ' is finised.'];
display(ProgressInfo);

