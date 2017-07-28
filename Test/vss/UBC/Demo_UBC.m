%% Demo for fitting functional mixed effect model using UBC Kalman filter
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;

rng(1)                                       % control the randomness

%% Simulation: functional mixed effect model example

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
logpara0 = [0;                                    % log of e  
         -5;-5;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                          % log of randomDiag

diffusePrior = 1e7;

%% Start point
SSM = fme2ss(n, fixedArray, randomArray, t, logpara0, diffusePrior);
tic
[~, ~, ~, loglik1] = kalman_filter(Y, SSM.TranMX, SSM.MeasMX,...
    SSM.DistCov, SSM.ObseCov, SSM.StateMean0, SSM.StateCov0, 'model', 1:m);
toc

%% Training parameters
tic
logparahat = fmeTraining_UBC(Y, fixedArray, randomArray, t, logpara0, diffusePrior)
toc

%% Model fitting
SSM = fme2ss(n, fixedArray, randomArray, t, logparahat, diffusePrior);

tic
[x, V, ~, loglik2] = kalman_smoother(Y, SSM.TranMX, SSM.MeasMX,...
    SSM.DistCov, SSM.ObseCov, SSM.StateMean0, SSM.StateCov0, 'model', 1:m);
toc

%% Group-average
k = 1;
SmoothedStates_UBC = x;
SmoothedStatesCov_UBC = zeros(d, m);
for j=1:m
    SmoothedStatesCov_UBC(:,j) = diag(V(:,:,j));
end
SmoothedStates95Upper_UBC = SmoothedStates_UBC + 1.96*sqrt(SmoothedStatesCov_UBC);
SmoothedStates95Lower_UBC = SmoothedStates_UBC - 1.96*sqrt(SmoothedStatesCov_UBC);

plot(t, SmoothedStates_UBC(k,:),...
    t, SmoothedStates95Upper_UBC(k,:), '--',...
    t, SmoothedStates95Lower_UBC(k,:), '--')
title('Group average: UBC')

%% Subject-fit

YFitted_UBC = zeros(n, m);
YFittedCov_UBC = zeros(n, m);
for j=1:m
    YFitted_UBC(:,j) = SSM.MeasMX(:,:,j)*x(:,j);
    YFittedCov_UBC(:,j) = diag(SSM.MeasMX(:,:,j)*V(:,:,j)*SSM.MeasMX(:,:,j)');
end
YFitted95Upper_UBC = YFitted_UBC + 1.96*sqrt(YFittedCov_UBC);
YFitted95Lower_UBC = YFitted_UBC - 1.96*sqrt(YFittedCov_UBC);

for n_i = 1:n
    figure;
    plot(t, YFitted_UBC(n_i, :),...
        t, Y(n_i,:),...
        t, YFitted95Upper_UBC(n_i, :), '--',...
        t, YFitted95Lower_UBC(n_i, :), '--')
    title(strcat('Subject fit: UBC n=', num2str(n_i)))
end
