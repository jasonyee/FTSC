%% Heterogeneous Random Effects, multiple simulations
clear;clc;

sample_sim = 30;

nSim = 50;
group_size = 100;
var_random1 = 50;
var_random2 = 200;
var_random3 = 100;
var_noise = 2;

path_result = 'Y:\Users\Jialin Yi\output\paper simulation\VaryClusters\data\';

load(strcat(path_result, num2str(nSim),'-', num2str(group_size),'-',...
    num2str(var_random1),'-', num2str(var_random2),'-',...
    num2str(var_random3),'-',num2str(var_noise), '.mat'));

%% Spaghetti plot with group average fit
nClusters = size(FixedEffect,1);
ClusterMembers =  ClusteringMembers(nClusters, ClusterIDs_simu(:,sample_sim));
SpaghettiPlot(data, sample_sim, nClusters, ClusterMembers, logpara_hats(:,:,sample_sim));
