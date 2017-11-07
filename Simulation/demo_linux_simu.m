%% Homogeneous Random Effects, multiple simulations
clear;clc;

sample_sim = 24;

nSim = 50;
group_size = 100;
var_random = 100;
var_noise = 1;

path_result = 'Y:\Users\Jialin Yi\output\paper simulation\FixNClusters\data\';

load(strcat(path_result, num2str(nSim),'-', num2str(group_size),'-',...
    num2str(var_random),'-', num2str(var_noise), '.mat'));

%% Spaghetti plot with group average fit
nClusters = size(FixedEffect,1);
ClusterMembers =  ClusteringMembers(nClusters, ClusterIDs_simu(:,sample_sim));
SpaghettiPlot(data, sample_sim, nClusters, ClusterMembers, logpara_hats(:,:,sample_sim));
