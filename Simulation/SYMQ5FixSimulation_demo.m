clear;clc;
% Specify data I/O
Path_InputData = 'Y:\Users\Jialin Yi\output\paper simulation\FixNClusters\data\';
Path_OutputSpaghetti = 'Y:\Users\Jialin Yi\output\paper simulation\FixNClusters\Spaghetti Plot\';
Path_OutputSubject = 'Y:\Users\Jialin Yi\output\paper simulation\FixNClusters\Subject Fit\';
Plot_filetype = '.pdf';

% Simulation scenario
nSim = 10;
group_size = 20;
var_random = 900;
var_noise = 9;

Simu = 9;

% loading data
load(strcat(Path_InputData, ...
            num2str(nSim), '-', num2str(group_size), '-', ...
            num2str(var_random), '-', num2str(var_noise),...
            '.mat'));
        
nClusters = size(FixedEffect,1);
ClusterMembers =  ClusteringMembers(nClusters, ClusterIDs_simu(:,Simu));     
SpaghettiPlot(data, Simu, nClusters, ClusterMembers, logpara_hats(:,:,Simu));
