%% DSSClustering
%  DSSClustering classifies the subjects to the fixed number of clusters
%  and returns the parameters for each cluster.

function [ ClusterIDs, ClusterMembers, Theta, SwitchHistory] = ...
    DSSClustering(dataset, OBtime, nClusters, ...
                fixedArray, randomArray, MAX_LOOP)
%Input:
%   -dataset: (i,t) is the data for subject i at observation t, n-by-T.
%   -OBtime: (t) is the time for the observation t, 1-by-T.
%   -nClusters: the fixed number of clusters.
%   -fixedArray: 1-by-p array for the fixed effect factors.
%   -randomArray: 1-by-q array for the random effect factors
%   -MAX_LOOP: the maximum loop inside the classication algorithm.
%Ouput:
%   -ClusterIDs: (i) is the cluster id to which subject i belongs, n-by-1.
%   -ClusterMembers: {k} is a 1-by-n_k array stores all cluster members,
%   1-by-nCluster.
%   -Theta: (:,k) is the fitting parameter for cluster k, dim of
%   para-by-nClusters.
%   -SwitchHistory: an array that stores the switches number in each loop

    % Initialize
    [n, ~] = size(dataset);
    q = length(randomArray); 
    diffusePrior = 1e7;
    logpara0 = [0;                                      % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                         % log of randomDiag
    
    ClusterMembers = cell(1, nClusters);
    Theta = zeros(length(logpara0), nClusters);
    
    %k-means clustering
    ClusterIDs = kmeans(dataset, nClusters);
    for k = 1:nClusters
        ClusterIndex = find(ClusterIDs == k);
        ClusterMembers{k} = ClusterIndex;
        kClusterData = dataset(ClusterIndex, :);
        Theta(:,k) = fmeTraining(kClusterData, OBtime, fixedArray, randomArray, logpara0, diffusePrior);
    end
    
    Switches = 1;
    loopNum = 0;
    SwitchHistory = [];
    
    while ~ShouldStop(Switches, loopNum, MAX_LOOP)
        Switches = 0;
        
        for i=1:n
            oldClusterID = ClusterIDs(i);
            oldClusterMembers = ClusterMembers{oldClusterID};
            % leave out the ith subject
            oldClusterMembers(oldClusterMembers == i) = [];
            oldLeaveOneClusterData = dataset(oldClusterMembers,:);
            
            % reclassifying the ith subject
            logPostProb = zeros(1, nClusters);
            for k=1:nClusters
                if k == oldClusterID
                    LeaveOneClusterData = oldLeaveOneClusterData;
                else
                    LeaveOneClusterData = dataset(ClusterMembers{k},:);
                end
                logPostProb(k) = fmeCondProb(LeaveOneClusterData, dataset(i,:), OBtime, fixedArray, randomArray, Theta(:,k), diffusePrior);
            end
            [~, newClusterID] = max(logPostProb);
            
            % updating the clustering
            if newClusterID ~= oldClusterID
                % id
                ClusterIDs(i) = newClusterID;
                % members
                newClusterMembers = ClusterMembers{newClusterID};
                ClusterMembers{newClusterID} = [newClusterMembers; i];
                ClusterMembers{oldClusterID} = oldClusterMembers;
                Switches = Switches + 1;
            end
        end
        
        % updating theta
        for k = 1:nClusters
            Theta(:,k) = fmeTraining(dataset(ClusterMembers{k},:), OBtime, fixedArray, randomArray, logpara0, diffusePrior);
        end
        loopNum = loopNum + 1;
        
        SwitchHistory = [SwitchHistory, Switches];
    end
end

