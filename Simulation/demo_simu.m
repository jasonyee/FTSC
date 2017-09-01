%%  Sensitivity analysis, switches plot and random subject fit plotting
%   change the truth id accordingly when analyzing different simulations
%   -FTSC2

%% loading clustering result
clear;
clc;

dataGen = '1';
NumC = '3';

simul = 'C:\Users\jialinyi\Documents\MATLAB\FTSC\Simulation\result\simu';

load(strcat(simul, num2str(dataGen),'_',num2str(NumC), 'C.mat'));

%% clustering running time
fprintf('The clustering algorithm running time is %.2f minutes.\n', clustertime/60)

%% preallocation
% get data in each cluster
ClusterData = ClusteringData(dataset, ClusterMembers);
% SSMTotal is a cell array of SSM for all batch data
SSM_kalman = cell(1, nClusters);

diffusePrior = 1e7;
ConfidenceLevel = 0.95;     % confidence level

%% sensitivity analysis
% truth 
TrueID = [ones(50,1); 2*ones(50,1); 3*ones(50,1)];
TrueMembers = ClusteringMembers(nClusters, TrueID);

% wald's minimum variance
WaldMembers = ClusteringMembers(nClusters, WaldClusterID);
fprintf('kmeans clustering: \n')
SensTable(TrueMembers, WaldMembers)

% state-space model clustering
fprintf('State-space model clustering: \n')
SensTable(TrueMembers, ClusterMembers)


%% Switches plot
plot(SwitchHistory);
title(strcat('switches in each iteration'))

%% Subject-fit plotting
nSubj = 9;

% get scale for dataset
ymin = min(min(dataset));
ymax = max(max(dataset));

for k=1:nClusters
    
    Y = ClusterData{k};
    Members = ClusterMembers{k};
    [n, ~] = size(Y);
    
    % Constructing SSM structures for one cluster
    SSM_kalman{k} = ...
        fmeRandomSinPriorBuiltIn(n, t, logparahat(:,k), diffusePrior);    
    [~, logLikSmooth, Output_builtin] = smooth(SSM_kalman{k}, Y');
    
    RandomSubjFitBuiltIn(nSubj, Y, Members, SSM_kalman{k}, Output_builtin, [ymin, ymax]);
end
