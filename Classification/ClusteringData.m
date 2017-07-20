%% ClusteringData
%  ClusteringData returns a cell that contains the data for each cluster

function ClusterData = ClusteringData(dataset, ClusterMembers)
%Input:
%   -dataset: all batch data
%   -ClusterMembers: {k} is the ids of the kth cluster
%Ouput:
%   -ClusterData: {k} is the data of the kth cluster

    nClusters = length(ClusterMembers);
    ClusterData = cell(1, nClusters);
    for k = 1:nClusters
        ClusterData{k} = dataset(ClusterMembers{k},:);
    end
end

