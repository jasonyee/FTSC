%% Urinary severity data, built-in, cubic spline(F), sin prior(R)
%  Adding the following folders to the path:
%   -FTSC
% this program uses the all-in-one FTSC function

%% Clear
clear;
clc;

%% Data I/O

path_data = 'Y:\Users\Jialin Yi\data\URINSEV\';

path_result = 'Y:\Users\Jialin Yi\output\URINSEV\AllinOne\';

%% Clustering setting
nClusters = 3;
MAX_LOOP = 20;
logpara0 = [1;10;6;-5;0];
k = 3;

%% First part of the partition data: Week 4-24
% load data
load(strcat(path_data, 'urinsev_dif_',num2str(nClusters),'C.mat'));
dataset = urinsev_dif;

% get time points
[~, m] = size(dataset);
t = (1:m)/m;

% clustering starts
tic;
[ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
    FTSC(dataset, nClusters, k, logpara0, MAX_LOOP);
clustertime = toc;

% convergence of algorithm
subplot(2, 5, nClusters);
plot(SwitchHistory)
title(strcat('Switches when', {' '},...
            'URINSEV', {', '}, ...
            'nClusters=', num2str(nClusters)));

% save result
save(strcat(path_result, 'URINSEV_dif_FC_',num2str(nClusters),'C.mat'));

ProgressInfo = ['URINSEV ', ...
    ': nClusters = ', num2str(nClusters), ' is finised.'];
display(ProgressInfo);

