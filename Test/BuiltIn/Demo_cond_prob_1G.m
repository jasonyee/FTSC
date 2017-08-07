%% Test for condtional probability 1 group unshuffled
%   -FTSC

%% Clear
rng(1)                                       % control the randomness

nClusters = 2;

m = 30;                                       % number of observations
t = (1:m)/m;
p = 1;                                        % # of fixed effects
q = 1;                                        % # of random effects

%% Simulation: Group 1
n1 = 20;                                       % number of subjects
sigma_e = 1;                                  % variance of white noise
realFixedEffect1 = 7*sin(2*pi*t + pi/4);              % p-by-m
realRandomEffect1 = randn(n1,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY1 = repmat(realFixedEffect1, [n1,1]) + realRandomEffect1;

Y1 = realY1+ sqrt(sigma_e)*randn(n1,m);


%% Shuffle data
% Y1 = Y1(randperm(size(Y1,1)),:);

%% Model setting

fixedArray = ones(1,p);
randomArray = ones(1,q);

% Start point
logpara0 = [0;                                    % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                          % log of randomDiag

diffusePrior = 1e7;

%% group 1
[logparahat1, fval1] = ...
        fmeTraining(@BuiltIn, Y1, fixedArray, randomArray, t, logpara0, diffusePrior);

    
%% Fitting SSM model
% group 1
SSMTotal = fme2ss(n1, fixedArray, randomArray, t, logparahat1, diffusePrior);

Algo = @BuiltIn;
Switches = 0;
logCondProb = zeros(n1,1);


%% logCondProb for group 1

for i=1:n1
    subjData = Y1(i,:);
    oldClusterMembers = 1:n1;
    % leave out the ith subject
    oldClusterMembers(oldClusterMembers == i) = [];
    oldLeaveOneClusterData = Y1(oldClusterMembers,:);
    

    LeaveOneClusterData = oldLeaveOneClusterData;
    logCondProb(i) = fmeCondProb(Algo, LeaveOneClusterData, subjData, SSMTotal, p, q);

    fprintf(strcat('Subject ', num2str(i), ':\n'));
    fprintf('log-conditional probability computing completed. \n')
end

logCondProb