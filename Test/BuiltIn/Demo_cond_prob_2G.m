%% Test for Conditional Probability using VSS, unshuffled
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
realFixedEffect1 = 5 * sin(2*pi*t);             % p-by-m
realRandomEffect1 = randn(n1,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY1 = repmat(realFixedEffect1, [n1,1]) + realRandomEffect1;

Y1 = realY1+ sqrt(sigma_e)*randn(n1,m);



%% Simulation: Group 2
n2 = 20;                                      % number of subjects
sigma_e = 1;                                  % variance of white noise

realFixedEffect2 = 7 * sin(2*pi*t + pi/4);              % p-by-m
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
% group 1
SSMp1(1) = fme2ss(n1+1, fixedArray, randomArray, t, logparahat(:,1), diffusePrior);
SSMm1(1) = fme2ss(n1-1, fixedArray, randomArray, t, logparahat(:,1), diffusePrior);

% group 2
SSMp1(2) = fme2ss(n2+1, fixedArray, randomArray, t, logparahat(:,2), diffusePrior);
SSMm1(2) = fme2ss(n2-1, fixedArray, randomArray, t, logparahat(:,2), diffusePrior);

Algo = @BuiltIn;
Switches = 0;
logCondProb = zeros(n1+n2, nClusters);


%% logCondProb for subjects from group 1
correct_G1 = 0;
for i=1:n1
    % compute the logcondprob for cluster 1
    Members1 = 1:n1;
    Members1(Members1 == i) = [];
    logCondProb(i,1) = logCondProb0(1) - Algo(SSMm1(1), Y1(Members1,:));
    
    % compute the logcondprob for cluster 2
    logCondProb(i,2) = Algo(SSMp1(2), [Y2; Y1(i,:)]) - logCondProb0(2);
    
    if logCondProb(i,1) > logCondProb(i,2)
        correct_G1 = correct_G1 + 1;
    end
end

%% logCondProb for subjects from group 2
correct_G2 = 0;
for j=1:n2
    % compute the logcondprob for cluster 1
    logCondProb(n1+j,1) = Algo(SSMp1(1), [Y1; Y2(j,:)]) - logCondProb0(1);
    
    % compute the logcondprob for cluster 2
    Members2 = 1:n2;
    Members2(Members2 == j) = [];
    logCondProb(n1+j,2) = logCondProb0(2) - Algo(SSMm1(2), Y2(Members2,:));
    
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

%% Group 1 state space model
SSM_G1 = fme2ss(n1, fixedArray, randomArray, t, logparahat(:,1), diffusePrior);
[logL_G1, Output_G1] = BuiltInSmoother(SSM_G1, Y1);

%% Group 2 state space model
SSM_G2 = fme2ss(n2, fixedArray, randomArray, t, logparahat(:,2), diffusePrior);
[logL_G2, Output_G2] = BuiltInSmoother(SSM_G2, Y2);

%% group average
k = 1; % the real fixed effect state parameter
ConfidenceLevel = 0.95; % confidence level
% group 1
[Smoothed_G1, SmoothedVar_G1] =...
StatesMeanVar(Output_G1, 'built-in', 'smooth');
[Smoothed95Upper_G1, Smoothed95Lower_G1] = ...
NormalCI(Smoothed_G1, SmoothedVar_G1, ConfidenceLevel);
% group 2
[Smoothed_G2, SmoothedVar_G2] =...
StatesMeanVar(Output_G2, 'built-in', 'smooth');
[Smoothed95Upper_G2, Smoothed95Lower_G2] = ...
NormalCI(Smoothed_G2, SmoothedVar_G2, ConfidenceLevel);


%% Misclassified subject
r = 20;
figure;
plot(t, Y1(r,:),...
t, Smoothed_G1(k,:),...
t, Smoothed_G2(k,:),...
t, Smoothed95Upper_G1(k,:), '--',...
t, Smoothed95Lower_G1(k,:), '--',...
t, Smoothed95Upper_G2(k,:), ':',...
t, Smoothed95Lower_G2(k,:), ':');
legend('raw', 'group 1', 'group 2');
title(strcat('misclassified subhject, n=', num2str(r)));

%% subject-fit of misclassified subject : group 1

[yFittedMean_G1, yFittedVar_G1] = SpaceMeanVar(Output_G1, SSM_G1, 'built-in', 'smooth');

[yFitted95Upper_G1, yFitted95Lower_G1] = ...
NormalCI(yFittedMean_G1, yFittedVar_G1, ConfidenceLevel);

%% subject-fit of misclassified subject : group 2

[logL_G2p1, Output_G2p1] = BuiltInSmoother(SSMp1(2), [Y2; Y1(r,:)]);

[yFittedMean_G2, yFittedVar_G2] = SpaceMeanVar(Output_G2p1, SSMp1(2), 'built-in', 'smooth');

[yFitted95Upper_G2, yFitted95Lower_G2] = ...
NormalCI(yFittedMean_G2, yFittedVar_G2, ConfidenceLevel);

%% plot the subject-fit of the misclassified subject

figure;
plot(t, Y1(r,:),...
t, yFittedMean_G1(r,:),...
t, yFittedMean_G2(end,:),...
t, yFitted95Upper_G1(r,:), '--',...
t, yFitted95Lower_G1(r,:), '--',...
t, yFitted95Upper_G2(end,:), ':',...
t, yFitted95Lower_G2(end,:), ':');
legend('raw', 'group 1 fit with --', 'group 2 fit with :');
title(strcat('misclassified subject, n=', num2str(r)));







