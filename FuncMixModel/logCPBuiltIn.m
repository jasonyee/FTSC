function logP =...
    logCPBuiltIn(dataset, nClusters, ClusterIDs, ClusterMembers,...
                logLik, logparahat,diffusePrior, KFlag)
%logCPBuiltIn returns the leave-one log conditional probability 
%   using functional mixed effect model clustering, see Guo and Landis (2017)
%Input:
%   -dataset is subj-by-time data matrix.
%   -nClusters is the desired number of clusters.
%   -ClusterIDs is a n-by-1 array indicating the belonging cluster.
%   -ClusterMembers is a 1-by-nClusters cell array of members in each.
%   -logLik stores the log likelihood for each cluster.
%   -logparahat stores the MLEs of state space model for each cluster.
%   -diffusePrior is the diffuse variance for fixed effect.
%   -KFlag controls whether we should use Koopman's algorithm.
%Output:
%   -logP stores the leave-one log conditional probability.


% get nSubj and time points
[n, T] = size(dataset);
t = (1:T)/T;

logP = zeros(n, nClusters);

% SSMTotal is an cell array of ssm objects for all batch data
SSMTotal = cell(1, nClusters);

for k=1:nClusters
    % Constructing ssm objects for all batch data
    SSMTotal{k} = ...
        fmeRandomSinPriorBuiltIn(n, t, logparahat(:,k), diffusePrior);
end
    
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
    [~, leaveOnelogLik, ~] = filter(leaveOneSSM, leaveOneData', 'Univariate', KFlag);
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
        [~, includeOnelogLik, ~] = filter(includeOneSSM, includeOneData',  'Univariate', KFlag);
        logCondProb(cID) = includeOnelogLik - logLik(cID);
    end


    % record the leave-one log conditional probability for 
    % cross validation
    logP(i,:) = logCondProb;

end % loop over subjects end


end

