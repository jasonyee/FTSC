function ClusterMembers = ClusteringMembers(nClusters, ClusterIDs)
%ClusteringMembers returns a cell array of members in each clusters
%   ClusterMembers is 1-by-nClusters
%       ClusterMembers{k} is a column vector
    
    ClusterMembers = cell(1, nClusters);
    for k=1:nClusters
        ClusterMembers{k} = find(ClusterIDs == k);
    end
    
end

