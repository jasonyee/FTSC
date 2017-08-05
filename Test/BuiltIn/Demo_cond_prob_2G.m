%% Test for DSS2Step and DSSFull using MATLAB's built-in algorithm 
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;
rng(2)                                       % control the randomness

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

%% Training parameters: Group 1
tic;
[logparahat1, fval1] = fmeTraining(@BuiltIn, Y1, fixedArray, randomArray, t, logpara0, diffusePrior);
opti1 = toc;

fprintf('MLE for Group 1 takes %d seconds.\n', opti1);
fprintf('The Group 1 estimated variance of measurement error is %d .\n', exp(logparahat1(1)));
fprintf('The Group 1 estimated lambda_b is %d .\n', exp(logparahat1(2)));
fprintf('The Group 1 estimated lambda_a is %d .\n', exp(logparahat1(3)));
fprintf('The Group 1 estimated sigma^2_1 is %d .\n', exp(logparahat1(4)));
fprintf('The Group 1 estimated sigma^2_2 is %d .\n', exp(logparahat1(5)));

%% Training parameters: Group 2
tic;
[logparahat2, fval2] = fmeTraining(@BuiltIn, Y2, fixedArray, randomArray, t, logpara0, diffusePrior);
opti2 = toc;

fprintf('MLE for Group 2 takes %d seconds.\n', opti2);
fprintf('The Group 2 estimated variance of measurement error is %d .\n', exp(logparahat2(1)));
fprintf('The Group 2 estimated lambda_b is %d .\n', exp(logparahat2(2)));
fprintf('The Group 2 estimated lambda_a is %d .\n', exp(logparahat2(3)));
fprintf('The Group 2 estimated sigma^2_1 is %d .\n', exp(logparahat2(4)));
fprintf('The Group 2 estimated sigma^2_2 is %d .\n', exp(logparahat2(5)));

%% State-space model: Group 1 and Group 2
SSMTotal1 = fme2ss(n, fixedArray, randomArray, t, logparahat1, diffusePrior);

SSMTotal2 = fme2ss(n, fixedArray, randomArray, t, logparahat2, diffusePrior);


%% log condtional probability
tic;
logCondProb1 = fmeCondProb(@BuiltIn, Y1(1:end-1,:), Y1(end,:), SSMTotal1, p, q);
condprobtime1 = toc;
%%
tic;
logCondProb2 = fmeCondProb(@BuiltIn, Y2, Y1(end,:), SSMTotal2, p, q);
condprobtime2 = toc;





