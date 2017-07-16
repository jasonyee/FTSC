%% Testing KF using kalman_filter and fme example..........PASS
%  Adding the corresponding folder to the path

%% Clear
clear;
clc;

rng('default')                                       % control the randomness

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

%% Model fitting

d = 42;
diffusePrior = 1e7;

tic
output_arg = fme2KF(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior, false);
toc

tic
[x, V, VV, loglik] = fme2kalman_filter(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior);
toc

%% Filtering
%  KF
fixedEffectMeanhat1 = output_arg.FilteredMean(d,:);
fixedEffectCovhat1 = reshape(output_arg.FilteredCov(d,d,:), [1, m]);

%  kalman_filter
fixedEffectMeanhat2 = x(d,:);
fixedEffectCovhat2 = reshape(V(d,d,:), [1,m]);

% Plotting
subplot(1,2,1)
plot(t, fixedEffectMeanhat1, t, fixedEffectMeanhat2);
legend('KF', 'UBC');
title('Filtered Mean');

subplot(1,2,2)
plot(t, fixedEffectCovhat1, t, fixedEffectCovhat2);
legend('KF', 'UBC');
title('Filtered Variance');

