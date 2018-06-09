function [kmeans_CRate, kmeans_isSeparated, kmeans_cost, ...
    Y, SampleFixedEffect, RandomEffect, WhiteNoise, ...
    IniClusterIDs] = ... 
    data_gen_k_means(seed, FixedEffect, group_size, var_random, var_noise)
%FIXSIMULATION Simulation for FTSC with exogenous group effect
%   Detailed explanation goes here

% Generating data
[nGroup, T] = size(FixedEffect);
nsamples = nGroup*group_size;

t = (1:T)/T;

% fix random seed
rng(seed);

% random effect
RandomEffect = zeros(size(FixedEffect));
for j=1:nGroup
    RandomEffect((j-1)*group_size+1:j*group_size,:) = func_dev(group_size, t, var_random(j));
end

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

kmeans_CRate = CRate(kmeans_nbyn, group_size);

kmeans_cost = BalancedCost(kmeans_nbyn);

[~, kmeans_GroupNum] = max(kmeans_nbyn);

kmeans_isSeparated = (length(unique(kmeans_GroupNum)) == nGroup);

IniClusterIDs = kmeansID;
end

