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

    nClusters_real = length(RealClusterMembers);
    nClusters_algo = length(AlgoClusterMembers);
    SensMX = zeros(nClusters_real, nClusters_algo);
    
    %Sensitivity Table
    for d=1:nClusters_real
        for k=1:nClusters_algo
            newMembers = AlgoClusterMembers{k};
            oldMembers = RealClusterMembers{d};
            commMembers = intersect(newMembers, oldMembers);
            SensMX(d, k) = length(commMembers);
        end
    end
    
    % get variable names
    VarNames = repmat({}, 1, nClusters_algo);
    for k=1:nClusters_algo
        VarNames{k} = strcat('Cluster ', num2str(k));
    end
    
    % get row names
    RowNames = repmat({}, nClusters_real, 1);
    for i=1:nClusters_real
        RowNames{i} = strcat('Group ', num2str(i));
    end

    SensTable = ...
        array2table(SensMX, 'VariableNames', VarNames, 'RowNames', RowNames);
    
end

