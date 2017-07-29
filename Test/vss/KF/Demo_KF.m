%% Demo for fitting functional mixed effect model using KF
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
logL = -NlogLik_KF(Y, fixedArray, randomArray, t, logpara0, diffusePrior);

%% Training parameters
tic
logparahat = fmeTraining_KF(Y, fixedArray, randomArray, t, logpara0, diffusePrior)
toc

%% Model fitting
SSM = fme2ss(n, fixedArray, randomArray, t, logparahat, diffusePrior);
KalmanFit = KS(SSM.TranMX, SSM.DistMean, SSM.DistCov, SSM.MeasMX,...
    SSM.ObseCov, Y, SSM.StateMean0, SSM.StateCov0);

%% Group-average
k = 1;
SmoothedStates_KF = KalmanFit.SmoothedMean;
SmoothedStatesCov_KF = zeros(d, m);
for j=1:m
    SmoothedStatesCov_KF(:,j) = diag(KalmanFit.SmoothedCov(:,:,j));
end
SmoothedStates95Upper_KF = SmoothedStates_KF + 1.96*sqrt(SmoothedStatesCov_KF);
SmoothedStates95Lower_KF = SmoothedStates_KF - 1.96*sqrt(SmoothedStatesCov_KF);

plot(t, SmoothedStates_KF(k,:),...
    t, SmoothedStates95Upper_KF(k,:), '--',...
    t, SmoothedStates95Lower_KF(k,:), '--')
title('Group average: KF')

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

