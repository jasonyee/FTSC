function ClusterMembers = ClusteringMembers(nClusters, ClusterIDs)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    ClusterMembers = cell(1, nClusters);
    for k=1:nClusters
        ClusterMembers{k} = find(ClusterIDs == k);
    end
    
end

