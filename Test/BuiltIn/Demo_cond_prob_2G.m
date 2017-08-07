%% Test for fmeCond
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;
rng(1)                                       % control the randomness

nClusters = 2;

m = 30;                                       % number of observations
t = (1:m)/m;
p = 1;                                        % # of fixed effects
q = 1;                                        % # of random effects

%% Simulation: Group 1
n1 = 20;                                       % number of subjects
sigma_e = 1;                                  % variance of white noise
realFixedEffect1 = 5*sin(2*pi*t);              % p-by-m
realRandomEffect1 = randn(n1,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY1 = repmat(realFixedEffect1, [n1,1]) + realRandomEffect1;

Y1 = realY1+ sqrt(sigma_e)*randn(n1,m);

%% Simulation: Group 2
n2 = 20;                                       % number of subjects
sigma_e = 1;                                  % variance of white noise

realFixedEffect2 = 7*sin(2*pi*t + pi/4);              % p-by-m
realRandomEffect2 = randn(n2,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY2 = repmat(realFixedEffect2, [n2,1]) + realRandomEffect2;

Y2 = realY2+ sqrt(sigma_e)*randn(n2,m);

%% Truth 
n = n1+n2;
dataset = [Y1; Y2];
realClusterIDs = [ones(n1, 1); 2*ones(n2, 1)];
realClusterMembers = ClusteringMembers(nClusters, realClusterIDs);
realClusterData = ClusteringData(dataset, realClusterMembers);

ClusteringVisual(dataset, realClusterData, t);

prior = ones(1, nClusters)/nClusters;


%% Model setting

fixedArray = ones(1,p);
randomArray = ones(1,q);

% Start point
logpara0 = [0;                                    % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                          % log of randomDiag

diffusePrior = 1e7;

%% Training state-space model for each group
logparahat = zeros(5, nClusters);
fval = zeros(1, nClusters);
opti = zeros(1, nClusters);

SSMTotal = repmat(struct('TranMX', {}, 'DistMean', {}, 'DistCov', {}, ...
             'MeasMX', {}, 'ObseCov', {}, ...
             'StateMean0', {}, 'StateCov0', {}),nClusters, 1);
         
for k=1:nClusters
    tic;
    [logparahat(:,k), fval(k)] = ...
        fmeTraining(@BuiltIn, realClusterData{k}, fixedArray, randomArray, t, logpara0, diffusePrior);
    opti(k) = toc;
    
    fprintf(strcat('Group ', num2str(k), ':\n'));
    fprintf('MLE takes %d seconds.\n', opti(k));
    fprintf('The estimated variance of measurement error is %d .\n', exp(logparahat(1,k)));
    fprintf('The estimated lambda_b is %d .\n', exp(logparahat(2,k)));
    fprintf('The estimated lambda_a is %d .\n', exp(logparahat(3,k)));
    fprintf('The estimated sigma^2_1 is %d .\n', exp(logparahat(4,k)));
    fprintf('The estimated sigma^2_2 is %d .\n', exp(logparahat(5,k)));
    
    fprintf(strcat('Training ssm for group ', num2str(k), '\n'));
    SSMTotal(k) = fme2ss(n, fixedArray, randomArray, t, logparahat(:,k), diffusePrior);
    fprintf(strcat('Training for group ', num2str(k), ' completed \n'));
end


%% log conditional probability
Algo = @BuiltIn;
Switches = 0;
logCondProb = zeros(n, nClusters);

for i=1:n
    subjData = dataset(i,:);
    oldClusterID = realClusterIDs(i);
    oldClusterMembers = realClusterMembers{oldClusterID};
    % leave out the ith subject
    oldClusterMembers(oldClusterMembers == i) = [];
    oldLeaveOneClusterData = dataset(oldClusterMembers,:);
    
    for k=1:nClusters
        if k == oldClusterID
            LeaveOneClusterData = oldLeaveOneClusterData;
        else
            LeaveOneClusterData = dataset(realClusterMembers{k},:);
        end
        logCondProb(i, k) = fmeCondProb(Algo, LeaveOneClusterData, subjData, SSMTotal(k), p, q);
    end
    fprintf(strcat('Subject ', num2str(i), ':\n'));
    fprintf('log-conditional probability computing completed. \n')
end

%% posterior probability
Priors = repmat(prior, n, 1);
CondProbs = exp(logCondProb);
Posteriors = BayesUpdate(Priors, CondProbs);

% get variable names
VarNames = repmat({}, 1, nClusters);
for k=1:nClusters
    VarNames{k} = strcat('Group ', num2str(k));
end

% get row names
RowNames = repmat({}, n, 1);
for i=1:n
    RowNames{i} = strcat('Subject ', num2str(i));
end

PosteriorsTable = ...
    array2table(round(Posteriors,4), 'VariableNames', VarNames, 'RowNames', RowNames)









































