%% Testing KF&KS using kalman_filter and fme example..........PASS
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

%% Training parameters
%  Built-in
tic
logparahat = fmeTraining_built_in(Y, fixedArray, randomArray, t, logpara0, diffusePrior)
toc


%% Model fitting
%  Built-in
Md = Md_built_in(n, fixedArray, randomArray, t, logparahat, diffusePrior);
data = cell(m, 1);
for j=1:m
    data{j} = Y(:,j);
end
[~, logL_built_in, Output_built_in] = smooth(Md, data);


%% Group-average
k = 1;
%  Built-in
SmoothedStates_built_in = zeros(d, m);
SmoothedStatesCov_built_in = zeros(d, m);
for j=1:m
    SmoothedStates_built_in(:,j) = Output_built_in(j).SmoothedStates;
    SmoothedStatesCov_built_in(:,j) = diag(Output_built_in(j).SmoothedStatesCov);
end
SmoothedStates95Upper_built_in = SmoothedStates_built_in + 1.96*sqrt(SmoothedStatesCov_built_in);
SmoothedStates95Lower_built_in = SmoothedStates_built_in - 1.96*sqrt(SmoothedStatesCov_built_in);

plot(t, SmoothedStates_built_in(k,:),...
    t, realFixedEffect,...
    t, SmoothedStates95Upper_built_in(k,:), '--',...
    t, SmoothedStates95Lower_built_in(k,:), '--')
title('Group average: built in')

%% Subject-fit

YFitted = zeros(n, m);
YFittedCov = zeros(n, m);
for j=1:m
    YFitted(:,j) = Y(:,j) - Output_built_in(j).SmoothedObsInnov;
    YFittedCov(:,j) = diag(Output_built_in(j).SmoothedObsInnovCov);
end
YFitted95Upper = YFitted + 1.96*sqrt(YFittedCov);
YFitted95Lower = YFitted - 1.96*sqrt(YFittedCov);

for n_i = 1:n
    subplot(5, 4, n_i)
    plot(t, YFitted(n_i, :),...
        t, Y(n_i,:),...
        t, YFitted95Upper(n_i, :), '--',...
        t, YFitted95Lower(n_i, :), '--')
    title(strcat('Subject fit: built in n=', num2str(n_i)))
end