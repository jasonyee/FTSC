function ClusterData = ClusteringData(dataset, ClusterMembers)
%ClusteringData returns a cell array of data in each cluster
%Input:
%   -dataset: all batch data
%   -ClusterMembers: {k} is the members of the kth cluster
%Ouput:
%   -ClusterData: {k} is the data of the kth cluster

    nClusters = length(ClusterMembers);
    ClusterData = cell(1, nClusters);
    for k = 1:nClusters
        ClusterData{k} = dataset(ClusterMembers{k},:);
    end
end

