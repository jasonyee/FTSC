function [ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
    FTSC(dataset, nClusters, k, logpara0, MAX_LOOP)
%SSMBuiltInClustering returns a fixed number of clusters. 
%   using functional mixed effect model clustering, see Guo and Landis (2017)
%Input:
%   -dataset is subj-by-time data matrix.
%   -nClusters is the desired number of clusters.
%   -k is the parameter for k-nearest neighbors
%   -logpara0 is the starting value for MLE.
%   -MAX_LOOP is the maximum number of loops allowable.
%Output:
%   -ClusterIDs is a n-by-1 array indicating the belonging cluster.
%   -ClusterMembers is a 1-by-nClusters cell array of members in each
%   cluster.
%   -SwitchHistory records the number of switches in each step.
%   -logparahat stores the MLEs of state space model for each cluster.
%   -logLik stores the loglikelihood for each cluster

[IniClusterIDs, ~, ~] = KNNBuiltInClustering(dataset, nClusters, k);

[ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
    SSMBuiltInClustering(dataset, nClusters, IniClusterIDs, logpara0, MAX_LOOP);

end