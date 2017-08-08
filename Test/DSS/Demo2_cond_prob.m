%% Test for fmeCond using DSS, unshuffled
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
n1 = 20;                                      % number of subjects
sigma_e = 1;                                  % variance of white noise
realFixedEffect1 = 5*sin(2*pi*t);             % p-by-m
realRandomEffect1 = randn(n1,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY1 = repmat(realFixedEffect1, [n1,1]) + realRandomEffect1;

Y1 = realY1+ sqrt(sigma_e)*randn(n1,m);



%% Simulation: Group 2
n2 = 20;                                      % number of subjects
sigma_e = 1;                                  % variance of white noise

realFixedEffect2 = 7*sin(2*pi*t + pi/4);              % p-by-m
realRandomEffect2 = randn(n2,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY2 = repmat(realFixedEffect2, [n2,1]) + realRandomEffect2;

Y2 = realY2+ sqrt(sigma_e)*randn(n2,m);


%% Model setting

fixedArray = ones(1,p);
randomArray = ones(1,q);

% Start point
logpara0 = [0;                                    % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                          % log of randomDiag

diffusePrior = 1e7;

dataset = [Y1; Y2];
prior = ones(1, nClusters)/nClusters;

logparahat = zeros(length(logpara0), nClusters);
fval = zeros(1, nClusters);

%% group 1
[logparahat(:,1), fval(1)] = ...
        fmeTraining(@BuiltIn, Y1, fixedArray, randomArray, t, logpara0, diffusePrior);

%% group 2
[logparahat(:,2), fval(2)] = ...
        fmeTraining(@BuiltIn, Y2, fixedArray, randomArray, t, logpara0, diffusePrior); 
%%    
logCondProb0 = - fval;

%% Shuffle data
% Y1 = Y1(randperm(size(Y1,1)),:);
% Y2 = Y2(randperm(size(Y2,1)),:);

%% Fitting SSM model
SSM_G1 = fme2ss(n1+n2, fixedArray, randomArray, t, logparahat(:,1), diffusePrior);
SSM_G2 = fme2ss(n1+n2, fixedArray, randomArray, t, logparahat(:,2), diffusePrior);


Algo = @DSS2Step;
Switches = 0;
logCondProb = zeros(n1+n2, nClusters);

%% logCondProb for subjects from group 1
correct_G1 = 0;
for i=1:n1
    % compute the logcondprob for cluster 1
    Members1 = 1:n1;
    Members1(Members1 == i) = [];
    logCondProb(i,1) = fmeCondProb(Algo, Y1(Members1,:), Y1(i,:), SSM_G1, p, q);
    
    % compute the logcondprob for cluster 2
    logCondProb(i,2) = fmeCondProb(Algo, Y2, Y1(i,:), SSM_G2, p, q);
    
    if logCondProb(i,1) > logCondProb(i,2)
        correct_G1 = correct_G1 + 1;
    end
end

%% logCondProb for subjects from group 2
correct_G2 = 0;
for j=1:n2
    % compute the logcondprob for cluster 1
    logCondProb(n1+j,1) = fmeCondProb(Algo, Y1, Y2(j,:), SSM_G1, p, q);
    
    % compute the logcondprob for cluster 2
    Members2 = 1:n2;
    Members2(Members2 == j) = [];
    logCondProb(n1+j,2) = fmeCondProb(Algo, Y2(Members2,:), Y2(j,:), SSM_G2, p, q);
    
    if logCondProb(n1+j,1) < logCondProb(n1+j,2)
        correct_G2 = correct_G2 + 1;
    end
end

%% posterior probability
Priors = repmat(prior, n1+n2, 1);
CondProbs = exp(logCondProb);
Posteriors = BayesUpdate(Priors, CondProbs);
    
% get variable names
VarNames = repmat({}, 1, nClusters);
for k=1:nClusters
    VarNames{k} = strcat('Group ', num2str(k));
end

% get row names
RowNames = repmat({}, n1+n2, 1);
for i=1:n1+n2
    RowNames{i} = strcat('Subject ', num2str(i));
end

PosteriorsTable = ...
    array2table(round(Posteriors,4), 'VariableNames', VarNames, 'RowNames', RowNames)

SensTable = array2table([correct_G1, n1 - correct_G1; n2 - correct_G2, correct_G2],...
    'VariableNames', {'Cluster1', 'Cluster2'}, 'RowNames', {'Group1', 'Group2'})




