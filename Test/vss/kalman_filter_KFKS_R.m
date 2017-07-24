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

fixedDesign = repmat(ones(n,p),[1, 1, m]);    % n-by-p-by-m
randomDesign = repmat(ones(n,q),[1, 1, m]);   % n-by-q-by-m

%  Optimization
logpara0 = [3;                                      % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         5*ones(2*q,1)];                         % log of randomDiag

k = 42;
diffusePrior = 1e7;

%% Model fitting
%  KF
tic
output_arg_KF = fme2KF(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior, false);
toc
%  kalman_filter
tic
[x1, V1, VV1, loglik1] = fme2kalman_filter(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior);
toc
%  KS
tic
output_arg_KS = fme2KS(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior);
toc
%  kalman_smoother
tic
[x2, V2, VV2, loglik2] = fme2kalman_smoother(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior);
toc

%% Filtering
%  KF
fixedEffectMeanhat_KF = output_arg_KF.FilteredMean(k,:);
fixedEffectCovhat_KF = reshape(output_arg_KF.FilteredCov(k,k,:), [1, m]);

%  kalman_filter
fixedEffectMeanhat2 = x1(k,:);
fixedEffectCovhat2 = reshape(V1(k,k,:), [1,m]);

% Plotting
figure;
subplot(1,2,1)
plot(t, fixedEffectMeanhat_KF, t, fixedEffectMeanhat2);
legend('KF', 'UBC');
title('Filtered Mean');

subplot(1,2,2)
plot(t, fixedEffectCovhat_KF, t, fixedEffectCovhat2);
legend('KF', 'UBC');
title('Filtered Variance');

%% Smoothing
%  KS
fixedEffectMeanhat_KS = output_arg_KS.SmoothedMean(k, :);
fixedEffectCovhat_KS = reshape(output_arg_KS.SmoothedCov(k,k,:), [1, m]);

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





