%% Testing fme2ss using fme2KF, fme2KS, fme2dss............................PASS
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;

rng(1)                                       % control the randomness

%% Simulation
%  Data we need

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
%  Common setting for fme2ss, fme2KF

fixedArray = ones(1, p);    % 1-by-p
randomArray = ones(1, q);   % 1-by-q

logpara0 = [3;                                      % log of e  
         -5;-7;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                         % log of randomDiag

diffusePrior = 1e7;

%% Kalman filtering and smoothing
% fme2ss
tic
SSM = fme2ss(n, fixedArray, randomArray, t, logpara0, diffusePrior);
toc

%%
KFFit1 = KF(SSM.TranMX, SSM.DistMean, SSM.DistCov, SSM.MeasMX,...
    SSM.ObseCov, Y, SSM.StateMean0, SSM.StateCov0, false);

KSFit1 = KS(SSM.TranMX, SSM.DistMean, SSM.DistCov, SSM.MeasMX,...
    SSM.ObseCov, Y, SSM.StateMean0, SSM.StateCov0);

% fme2KF
fixedDesign = repmat(fixedArray,[n, 1, m]);    % n-by-p-by-m
randomDesign = repmat(randomArray,[n, 1, m]);   % n-by-q-by-m

KFFit2 = fme2KF(Y, fixedArray, randomArray, t, logpara0, diffusePrior, false);

% fme2KS

KSFit2 = fme2KS(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior);

%% Dynamic state space model

% fme2ss

[DSSFitCell1, loglik1, prior1] = dss_uni2step(SSM.TranMX, SSM.DistMean, SSM.DistCov,...
    SSM.MeasMX, SSM.ObseCov, Y, SSM.StateMean0, SSM.StateCov0);

% fme2dss

[DSSFitCell2, loglik2, prior2] = fme2dss(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior);

