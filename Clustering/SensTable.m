%% SensitivityAnalysis
%  SensitivityAnalysis compare the clustering produced by the algorithm
%  with the underlying true clustering

function SensTable = SensTable(RealClusterMembers, AlgoClusterMembers)
%Input:
%   -RealClusterMembers: {d} is an array contains the members in cluster d
%   -AlgoClusterMembers: {k} is an array contains the members in cluster k
%Output:
%   -SensTable: (d, k) is how many members in AlgoClusterMembers{k} come from
%   RealClusterMembers{d}.

    nClusters = length(RealClusterMembers);
    SensMX = zeros(nClusters, nClusters);
    
    %Sensitivity Table
    for d=1:nClusters
        for k=1:nClusters
            newMembers = AlgoClusterMembers{k};
            oldMembers = RealClusterMembers{d};
            commMembers = intersect(newMembers, oldMembers);
            SensMX(d, k) = length(commMembers);
        end
    end
    
    % get variable names
    VarNames = repmat({}, 1, nClusters);
    for k=1:nClusters
        VarNames{k} = strcat('Cluster ', num2str(k));
    end
    
    % get row names
    RowNames = repmat({}, nClusters, 1);
    for i=1:nClusters
        RowNames{i} = strcat('Group ', num2str(i));
    end

    SensTable = ...
        array2table(SensMX, 'VariableNames', VarNames, 'RowNames', RowNames);
    
end

