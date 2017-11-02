function [FTSC_CRate, FTSC_isSeparated, FTSC_cost, ...
    kmeans_CRate, kmeans_isSeparated, kmeans_cost, ...
    Y, SampleFixedEffect, RandomEffect, WhiteNoise, ...
    ClusterIDs, logparahat] = ... 
                    VarySimulation(seed, FixedEffect, group_size, var_random, var_noise)
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

% subplot(2,2,1)
% plot(SampleFixedEffect')
% ylim([-5, 5])
% title('fixed effect')
% subplot(2,2,2)
% plot(RandomEffect')
% ylim([-5, 5])
% title(strcat('random effect var scale', {' '}, num2str(var_random)))
% subplot(2,2,3)
% plot(WhiteNoise')
% title(strcat('measurement error var scale', {' '}, num2str(var_noise)))
% ylim([-5, 5])
% subplot(2,2,4)
% plot(SampleFixedEffect'+RandomEffect')
% title('signal')
% ylim([-5, 5])

% Truth                 
Y = SampleFixedEffect + RandomEffect + WhiteNoise;
TrueID = kron((1:nGroup)', ones(group_size,1));
TrueMemebers = ClusteringMembers(nGroup, TrueID);

% kmeans
kmeansID = kmeans(Y,nGroup);
kmeansMembers = ClusteringMembers(nGroup, kmeansID);

kmeans_nbyn = table2array(SensTable(TrueMemebers, kmeansMembers));

kmeans_CRate = CRate(kmeans_nbyn, group_size);

kmeans_cost = BalancedCost(kmeans_nbyn);

[~, kmeans_GroupNum] = max(kmeans_nbyn);

kmeans_isSeparated = (length(unique(kmeans_GroupNum)) == nGroup);

% FTSC
IniClusterIDs = kmeansID;
nClusters = nGroup;
[ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
    SSMBuiltInClustering(Y, nClusters, IniClusterIDs, logpara0, MAX_LOOP);

FTSC_nbyn = table2array(SensTable(TrueMemebers, ClusterMembers));

FTSC_CRate = CRate(FTSC_nbyn, group_size);

[~, FTSC_GroupNum] = max(FTSC_nbyn);

FTSC_isSeparated = (length(unique(FTSC_GroupNum)) == nGroup);

FTSC_cost = BalancedCost(FTSC_nbyn);

end

