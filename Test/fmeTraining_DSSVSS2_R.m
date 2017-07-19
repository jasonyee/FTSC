%% Testing fmeTraining using fme example...................................PASS
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

fixedArray = ones(1,p);    % fixed effect coefficients
randomArray = ones(1,q);   % random effect coefficients

%  Optimization
logpara0 = [0;                                      % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                         % log of randomDiag

diffusePrior = 1e7;

%% fmeTraining
tic
logparahat = fmeTraining(Y, t, fixedArray, randomArray, logpara0, diffusePrior);
toc
% compare to the result in DSSVSS2_R
