%% SensitivityAnalysis
%  SensitivityAnalysis compare the clustering produced by the algorithm
%  with the underlying true clustering

function SensTable = SensTable(RealClusterMembers, AlgoClusterMembers)
%Input:
%   -RealClusterMembers: {d} is an array contains the indexes in cluster d
%   -AlgoClusterMembers: {k} is an array contains the indexes in cluster k
%Output:
%   -SensTable: (d, k) is how many members in AlgoClusterMembers{k} come from
%   RealClusterMembers{d}.

    nClusters = length(RealClusterMembers);
    SensTable = zeros(nClusters, nClusters);
    
    %Sensitivity Table
    for d=1:nClusters
        for k=1:nClusters
            newMembers = AlgoClusterMembers{k};
            oldMembers = RealClusterMembers{d};
            commMembers = intersect(newMembers, oldMembers);
            SensTable(d, k) = length(commMembers);
        end
    end
end

