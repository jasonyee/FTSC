%% Testing fmeCondProb using fme example...................................PASS
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;

rng(1)                                       % control the randomness

%% ********Testing for the fme example*********


n = 20;                                       % number of subjects
m = 30;                                       % number of observations
t = (1:m)/m;
p = 1;                                        % # of fixed effects
q = 1;                                        % # of random effects
sigma_e = 1;                                  % variance of white noise

d = 2*(p+n*q);                                % dimension of states

realFixedEffect = 7*sin(2*pi*t);              % p-by-m
realRandomEffect = randn(n,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
Y = repmat(realFixedEffect, [n,1]) + realRandomEffect ... 
    + sqrt(sigma_e)*randn(n,m);

%% Model setting

fixedArray = ones(1, p);    % 1-by-p
randomArray = ones(1, q);   % n-by-q-by-m

%  Optimization
logpara0 = [0;                                      % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                         % log of randomDiag

diffusePrior = 1e7;

%% fmeCondProb
ClusterMem = 1:n-10;
subj = n;

ClusterData = Y(ClusterMem,:);
subdata = Y(subj, :);
tic
logCondProb = fmeCondProb(ClusterData, subdata, t, ...
                        fixedArray, randomArray, logpara0, diffusePrior)
toc
% compare to the result in DSSVSS1_R

%% newCondProb
tic
SSMArray = fme2ssArray(n, t, ...
                       fixedArray, randomArray, logpara0, diffusePrior);s

generateArray = toc

logCondProb1 = fmeCondProb1(ClusterData, subdata, SSMArray(length(ClusterMem)+1))
computingCondProb = toc