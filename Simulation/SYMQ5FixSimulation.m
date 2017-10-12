clear;clc;
% Generating data
group_size = 20;
nsamples = 3*group_size;
var_random = 9;
var_noise = 3;
T = 23;
t = (1:T)/T;
MAX_LOOP = 20;
logpara0 = [0.5;6;6;-5;0];

% fix random seed
rng(1);

% random effect
RandomEffect = func_dev(nsamples, t, var_random);
% white noise
WhiteNoise = sqrt(var_noise)*randn(nsamples, T);
% fixed effect
load('Y:\Users\Jialin Yi\output\SYMQ5\MATLAB\C3\FixedEffect.mat');
SampleFixedEffect = kron(FixedEffect, ones(group_size,1));
                 
% Truth                 
Y = SampleFixedEffect + RandomEffect + WhiteNoise;
TrueID = [ones(group_size,1); 2*ones(group_size,1); 3*ones(group_size,1)];
TrueMemebers = ClusteringMembers(3, TrueID);

% kmeans
kmeansID = kmeans(Y,3);
kmeansMembers = ClusteringMembers(3, kmeansID);

kmeans3by3 = table2array(SensTable(TrueMemebers, kmeansMembers));

kmeans_CRate = mean(max(kmeans3by3, [], 2))/group_size;

[~, kmeans_GroupNum] = max(kmeans3by3);

kmeans_isSeparated = (length(unique(kmeans_GroupNum)) == 3);

% FTSC
IniClusterIDs = kmeansID;
nClusters = 3;
[ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
    SSMBuiltInClustering(Y, nClusters, IniClusterIDs, logpara0, MAX_LOOP);

FTSC3by3 = table2array(SensTable(TrueMemebers, ClusterMembers));

FTSC_CRate = mean(max(FTSC3by3, [], 2))/group_size;

[~, FTSC_GroupNum] = max(FTSC3by3);

FTSC_isSeparated = (length(unique(FTSC_GroupNum)) == 3);