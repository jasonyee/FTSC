%%  SYMQ7: Sensitivity analysis, switches plot and random subject fit plotting
%   change the truth id accordingly when analyzing different simulations
%   -FTSC

%% loading clustering result
clear;
clc;

%% Data I/O
NumC = 3;

path_result = 'Y:\Users\Jialin Yi\output\SYMQ7\Model Selection\';

load(strcat(path_result, 'SYMQ7_dif_FC_', num2str(NumC),'C.mat'));

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

% wald's minimum variance
WaldMembers = ClusteringMembers(nClusters, WaldClusterID);
% state-space model clustering
fprintf('Functional clustering v.s. kmeans: \n')
SensTable(WaldMembers, ClusterMembers)

%% Switches plot
plot(SwitchHistory);
title(strcat('Switches when', {' '},...
        'SYMQ7', {', '}, ...
        'nClusters=', num2str(nClusters)));
    
%% Spaghetti plot with group average fit
GrewPoints = .8 * ones(1,3);

% get scale for dataset
ymin = min(dataset(:))-1;
ymax = max(dataset(:))+1;

f = figure;
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = strcat('Spaghetti plot for', {' '}, ...
                'SYMQ7', {', '}, ...
                'nClusters=',num2str(nClusters)); 
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';
for k=1:nClusters
    
    Y = ClusterData{k};
    [n, T] = size(Y);
    t = (1:T)/T;
    
    % Constructing ssm object
    SSM_kalman{k} = ...
        fmeRandomSinPriorBuiltIn(n, t, logparahat(:,k), diffusePrior);    
    [~, logLikSmooth, Output] = smooth(SSM_kalman{k}, Y');
    
    [Smoothed, SmoothedVar] =...
        StatesMeanVar(Output, 'built-in', 'smooth');

    [Smoothed95Upper, Smoothed95Lower] = ...
        NormalCI(Smoothed, SmoothedVar, ConfidenceLevel);
    
    subplot(1,nClusters,k,'Parent',p);
    plot(t, Y', 'Color', GrewPoints);
    hold on;
    plot(t, Smoothed(1,:),...
        t, Smoothed95Upper(1,:), '--',...
        t, Smoothed95Lower(1,:), '--');
    hold on;
    plot(t, zeros(1,T),'--');
    hold off;
    ylim([ymin, ymax]);
    plottitle = strcat('Cluster', num2str(k), ' n=', num2str(n));
    title(plottitle);
end

%% Subject-fit plotting
nSubj = min([9, min(cellfun('length', ClusterMembers))]);

% get scale for dataset
ymin = min(min(dataset))-1;
ymax = max(max(dataset))+1;

for k=1:nClusters
    
    Y = ClusterData{k};
    Members = ClusterMembers{k};
    [n, ~] = size(Y);
    
    % Constructing SSM structures for one cluster
    SSM_kalman{k} = ...
        fmeRandomSinPriorBuiltIn(n, t, logparahat(:,k), diffusePrior);    
    [~, logLikSmooth, Output_builtin] = smooth(SSM_kalman{k}, Y');
    
    f = figure;
    p = uipanel('Parent',f,'BorderType','none'); 
    p.Title = strcat('SYMQ7: subjects in Cluster',num2str(k)); 
    p.TitlePosition = 'centertop'; 
    p.FontSize = 12;
    p.FontWeight = 'bold';

    RandomSubjFitBuiltIn(nSubj, Y, Members, SSM_kalman{k}, Output_builtin, [ymin, ymax], p);
end
