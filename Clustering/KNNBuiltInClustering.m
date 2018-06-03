function [ClusterIDs, ClusterMembers, data] = KNNBuiltInClustering(dataset, nClusters, k)
%KNNBuiltInClustering returns a fixed number of clusters. 
%   imputing the missing values by k-nearest neighboring and kmeans for
%   clustering
%Input:
%   -dataset is subj-by-time data matrix.
%   -nClusters is the desired number of clusters.
%   -k is the parameter for k-nearest neighbors
%Output:
%   -ClusterIDs is a n-by-1 array indicating the belonging cluster.
%   -ClusterMembers is a 1-by-nClusters cell array of members in each
%   cluster.
%   -data is the imputed dataset.

data = knnimpute(dataset, k);
ClusterIDs = kmeans(data, nClusters);

ClusterMembers = ClusteringMembers(nClusters, ClusterIDs);

end

