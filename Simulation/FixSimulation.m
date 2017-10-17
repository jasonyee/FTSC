function [FTSC_CRate, FTSC_isSeparated, kmeans_CRate, kmeans_isSeparated, Y, ClusterIDs, logparahat] = ... 
                    FixSimulation(seed, FixedEffect, group_size, var_random, var_noise)
%FIXSIMULATION Simulation for FTSC with exogenous group effect
%   Detailed explanation goes here

% Generating data
[nGroup, T] = size(FixedEffect);
nsamples = nGroup*group_size;

t = (1:T)/T;
MAX_LOOP = 20;
logpara0 = [0.5;6;6;-5;0];

% fix random seed
rng(seed);

% random effect
RandomEffect = func_dev(nsamples, t, var_random);
% white noise
WhiteNoise = sqrt(var_noise)*randn(nsamples, T);
% fixed effect
SampleFixedEffect = kron(FixedEffect, ones(group_size,1));
                 
% Truth                 
Y = SampleFixedEffect + RandomEffect + WhiteNoise;
TrueID = kron((1:nGroup)', ones(group_size,1));
TrueMemebers = ClusteringMembers(nGroup, TrueID);

% kmeans
kmeansID = kmeans(Y,nGroup);
kmeansMembers = ClusteringMembers(nGroup, kmeansID);

kmeans_nbyn = table2array(SensTable(TrueMemebers, kmeansMembers));

kmeans_CRate = mean(max(kmeans_nbyn, [], 2))/group_size;

[~, kmeans_GroupNum] = max(kmeans_nbyn);

kmeans_isSeparated = (length(unique(kmeans_GroupNum)) == nGroup);

% FTSC
IniClusterIDs = kmeansID;
nClusters = nGroup;
[ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
    SSMBuiltInClustering(Y, nClusters, IniClusterIDs, logpara0, MAX_LOOP);

FTSC_nbyn = table2array(SensTable(TrueMemebers, ClusterMembers));

FTSC_CRate = mean(max(FTSC_nbyn, [], 2))/group_size;

[~, FTSC_GroupNum] = max(FTSC_nbyn);

FTSC_isSeparated = (length(unique(FTSC_GroupNum)) == nGroup);

end

