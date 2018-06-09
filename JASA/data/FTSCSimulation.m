function [FTSC_CRate, FTSC_isSeparated, FTSC_cost, ...
    SwitchHistory, logP, logLik, ...
    ClusterIDs, logparahat] = ... 
    FTSCSimulation(dataset, group_size, nClusters, IniClusterIDs, logpara0, MAX_LOOP)
%FIXSIMULATION Simulation for FTSC with exogenous group effect
%   Detailed explanation goes here

% Generating data


% Truth
TrueID = kron((1:nClusters)', ones(group_size,1));
TrueMemebers = ClusteringMembers(nClusters, TrueID);

% FTSC
[ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
    SSMBuiltInClustering(dataset, nClusters, IniClusterIDs, logpara0, MAX_LOOP);

FTSC_nbyn = table2array(SensTable(TrueMemebers, ClusterMembers));

FTSC_CRate = CRate(FTSC_nbyn, group_size);

[~, FTSC_GroupNum] = max(FTSC_nbyn);

FTSC_isSeparated = (length(unique(FTSC_GroupNum)) == nClusters);

FTSC_cost = BalancedCost(FTSC_nbyn);

end
