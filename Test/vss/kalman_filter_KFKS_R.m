%% Testing KF&KS using kalman_filter and fme example..........PASS
%  Adding the following folders to the path:
%   -FTSC
%   -Kalman
%   -KPMstats

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

fixedArray = ones(1,p);
randomArray = ones(1,q);

%  Optimization
logpara0 = [3;                                    % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         5*ones(2*q,1)];                          % log of randomDiag

diffusePrior = 1e7;

SSM = fme2ss(n, fixedArray, randomArray, t, logpara0, diffusePrior);

k = 1;

%% Model fitting
%  KF
tic
KalmanFilter = KF(SSM.TranMX, SSM.DistMean, SSM.DistCov, SSM.MeasMX, SSM.ObseCov, Y, SSM.StateMean0, SSM.StateCov0, false);
toc
%  kalman_filter
tic
[x1, V1, VV1, loglik1] = kalman_filter(Y, SSM.TranMX, SSM.MeasMX, SSM.DistCov, SSM.ObseCov, SSM.StateMean0, SSM.StateCov0);
toc
%  KS
tic
KalmanSmoother = KS(SSM.TranMX, SSM.DistMean, SSM.DistCov, SSM.MeasMX, SSM.ObseCov, Y, SSM.StateMean0, SSM.StateCov0);
toc
%  kalman_smoother
tic
[x2, V2, VV2, loglik2] = kalman_smoother(Y, SSM.TranMX, SSM.MeasMX, SSM.DistCov, SSM.ObseCov, SSM.StateMean0, SSM.StateCov0);
toc

%% Group-average
%  KS
fixedEffectMeanhat_KS = KalmanSmoother.SmoothedMean(k, :);
fixedEffectCovhat_KS = reshape(KalmanSmoother.SmoothedCov(k,k,:), [1, m]);

%  kalman_smoother
fixedEffectMeanhat4 = x2(k,:);
fixedEffectCovhat4 = reshape(V2(k,k,:), [1,m]);

% Plotting
figure;
subplot(1,2,1)
plot(t, fixedEffectMeanhat_KS, t, fixedEffectMeanhat4);
legend('KS', 'UBC');
title('Smoothed Mean');

subplot(1,2,2)
plot(t, fixedEffectCovhat_KS, t, fixedEffectCovhat4);
legend('KS', 'UBC');
title('Smoothed Variance');

%% Subject-fit






