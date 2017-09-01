function [ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP] =...
    SSMBuiltInClustering(dataset, nClusters, IniClusterIDs, logpara0, MAX_LOOP)
%SSMBuiltInClustering returns a fixed number of clusters. 
%   using functional mixed effect model clustering, see Guo and Landis (2017)
%Input:
%   -dataset is subj-by-time data matrix.
%   -nClusters is the desired number of clusters.
%   -IniClusterIDs is the cluster ids from a traditional clustering
%   method, like kmeans/Wald's minimum variance clustering.
%   -logpara0 is the starting value for MLE.
%   -MAX_LOOP is the maximum number of loops allowable.
%Output:
%   -ClusterIDs is a n-by-1 array indicating the belonging cluster.
%   -ClusterMembers is a 1-by-nClusters cell array of members in each
%   cluster.
%   -SwitchHistory records the number of switches in each step.
%   -logparahat stores the MLEs of state space model for each cluster.

% diffuse variance for fixed effect
diffusePrior = 1e7;

% get nSubj and time points
[n, T] = size(dataset);
t = (1:T)/T;

% 1. Get initial clustering using kmeans 
ClusterIDs = IniClusterIDs;
ClusterMembers = ClusteringMembers(nClusters, ClusterIDs);

% 2. Improve the initial clustering until stopping condtion is met.
NSwitches = 1;
loopNum = 0;
SwitchHistory = zeros(1, MAX_LOOP);

logP = zeros(n, nClusters);

while ~ShouldStop(NSwitches, loopNum, MAX_LOOP)
% ITERATION STEP STARTS HERE
% 3. Fitting each cluster using FuncMixModel and StateSpaceModel to get
% parameters and logLiks.

    loopNum = loopNum+1;
    
    NSwitches = 0;
    % get data in each cluster
    ClusterData = ClusteringData(dataset, ClusterMembers);
    % variables to store parameters, logLik, and SSMTotal
    logLik = zeros(1, nClusters);
    % each column is a set of parameters for each cluster
    logparahat = zeros(length(logpara0), nClusters);
    % SSMTotal is an cell array of ssm objects for all batch data
    SSMTotal = cell(1, nClusters);
    
    for k=1:nClusters
        Y = ClusterData{k};
        % MLE fitting
        [logparahat(:,k), logLik(k)] = ...
            fmeTrainingBuiltIn(Y, t, logpara0, diffusePrior);
        % Constructing ssm objects for all batch data
        SSMTotal{k} = ...
            fmeRandomSinPriorBuiltIn(n, t, logparahat(:,k), diffusePrior);
    end
    
% 4. Reclassifying each subjects using the posterior probability
    
    % variables to store the logCondProbs for one subject in each cluster
    logCondProb = zeros(1, nClusters);
    
    for i=1:n % loop over subjects
        
        oldID = ClusterIDs(i);
        oldMembers = ClusterMembers{oldID};
        % leave out i
        oldMembers(oldMembers == i) = [];
                
        % Computing the logCondProb
        
        % Cluster oldID: leave one
        leaveOneData = dataset(oldMembers,:);
        % Constructing leave-one ssm
        leaveOneNum = length(oldMembers);
        leaveOneSSM = SubSSMBuiltIn(leaveOneNum, SSMTotal{oldID});
        % logLik for leave-one data
        [~, leaveOnelogLik, ~] = filter(leaveOneSSM, leaveOneData');
        logCondProb(oldID) = logLik(oldID) - leaveOnelogLik;
        
        % Other Clusters: include one
        OtherClusters = 1:nClusters;
        OtherClusters(OtherClusters == oldID) = [];
        % compute logCondProbs for each other clusters
        for cID=OtherClusters
            % Cluster cID: include one
            includeOneMembers = [ClusterMembers{cID}; i];
            includeOneData = dataset(includeOneMembers, :);
            % Constructing include-one ssm
            includeOneNum = length(includeOneMembers);
            includeOneSSM = SubSSMBuiltIn(includeOneNum, SSMTotal{cID});
            % logLik for include-one data
            [~, includeOnelogLik, ~] = filter(includeOneSSM, includeOneData');
            logCondProb(cID) = includeOnelogLik - logLik(cID);
        end
        
        % get newID
        [newlogCondProb, newID] = max(logCondProb);
        
        if newID ~= oldID
            % updating ClusterIDs
            ClusterIDs(i) = newID;            
            % updating ClusterMembers
            ClusterMembers{oldID} = oldMembers;
            newMembers = ClusterMembers{newID};
            ClusterMembers{newID} = [newMembers; i];            
            % updating logLik
            logLik(oldID) = leaveOnelogLik;
            logLik(newID) = logLik(newID) + newlogCondProb;
            % update switches
            NSwitches = NSwitches + 1; 
        end
        
        % record the leave-one log conditional probability for 
        % cross validation
        logP(i,:) = logCondProb;
    
    end % loop over subjects end
    
    % log number of switches
    SwitchHistory(loopNum) = NSwitches;

% ITERATION STEP STOPS HERE
end

end

