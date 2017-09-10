function logP =...
    logCPDSS(dataset, nClusters, ClusterIDs, ClusterMembers,...
                logparahat,diffusePrior)
%logCPDSS returns the leave-one log conditional probability 
%   using dynamic state space model, see Guo and Landis (2017)
%Input:
%   -dataset is subj-by-time data matrix.
%   -nClusters is the desired number of clusters.
%   -ClusterIDs is a n-by-1 array indicating the belonging cluster.
%   -ClusterMembers is a 1-by-nClusters cell array of members in each.
%   -logparahat stores the MLEs of state space model for each cluster.
%   -diffusePrior is the diffuse variance for fixed effect.
%Output:
%   -logP stores the leave-one log conditional probability.


% get nSubj and time points
[n, T] = size(dataset);
t = (1:T)/T;

logP = zeros(n, nClusters);

% SSMTotal is an cell array of SSM structures for all batch data
SSMTotal = cell(1, nClusters);

for k=1:nClusters
    % Constructing SSM structures for all batch data
    SSMTotal{k} = ...
        fmeRandomSinPrior(n, t, logparahat(:,k), diffusePrior);
end
    
% variables to store the logCondProbs for one subject in each cluster
logCondProb = zeros(1, nClusters);
llk = zeros(1, nClusters);

for i=1:n % loop over subjects
    Yi = dataset(i,:);
    oldID = ClusterIDs(i);
    oldMembers = ClusterMembers{oldID};
    nSubj_oldID = length(oldMembers);
    % leave out i
    oldMembers(oldMembers == i) = [];

    % Computing the logCondProb

    % Cluster oldID: leave one
    leaveOneData = dataset(oldMembers,:);
    % Constructing SSM for the old cluster it belongs to
    SSM_oldID = SubSSM(nSubj_oldID, SSMTotal{oldID});
    % logLik for leave-one data
    [llk(oldID), KalmanFull] = DSSFull(SSM_oldID, [leaveOneData;Yi]);
    logCondProb(oldID) = KalmanFull(end).logLik;

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
        includeOneSSM = SubSSM(includeOneNum, SSMTotal{cID});
        % logLik for include-one data
        [llk(cID), KalmanFull] = DSSFull(includeOneSSM, includeOneData);
        logCondProb(cID) = KalmanFull(end).logLik;
    end
    
    % record the leave-one log conditional probability for 
    % cross validation
    logP(i,:) = logCondProb;

end % loop over subjects end


end

