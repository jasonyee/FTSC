%% Test for fit for 2 groups, unshuffled
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;
rng(1)                                       % control the randomness

nClusters = 2;

m = 30;                                       % number of observations
t = (1:m)/m;
p = 1;                                        % # of fixed effects
q = 1;                                        % # of random effects

%% Model setting

fixedArray = ones(1,p);
randomArray = ones(1,q);

% Start point
logpara0 = [0;                                    % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                          % log of randomDiag

diffusePrior = 1e7;

%% Simulation: Group 1
n1 = 20;                                      % number of subjects
sigma_e = 1;                                  % variance of white noise
realFixedEffect1 = 5 * sin(2*pi*t);             % p-by-m
realRandomEffect1 = randn(n1,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY1 = repmat(realFixedEffect1, [n1,1]) + realRandomEffect1;

Y1 = realY1+ sqrt(sigma_e)*randn(n1,m);


%% Simulation: Group 2
n = 20;                                      % number of subjects
sigma_e = 1;                                  % variance of white noise

realFixedEffect = 7 * sin(2*pi*t + pi/4);              % p-by-m
realRandomEffect = randn(n,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY = repmat(realFixedEffect, [n,1]) + realRandomEffect;

Y = realY+ sqrt(sigma_e)*randn(n,m);


%% Training parameters: Built_in filter

tic;
[logparahat_built_in, fval_built_in] = fmeTraining(@BuiltIn, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
opti_built_in = toc;

logparahat_built_in

%% Model fitting: Built_in smoother

SSM_built_in = fme2ss(n, fixedArray, randomArray, t, logparahat_built_in, diffusePrior);

[logL_built_in, Output_built_in] = BuiltInSmoother(SSM_built_in, Y);

fprintf('The built-in maximized log-likelihood is %d .\n', logL_built_in);

%% Group-average
k = 1;  %  the real fixed effect state parameter
ConfidenceLevel = 0.95;     % confidence level

%  built-in
[Smoothed_built_in, SmoothedVar_built_in] =...
    StatesMeanVar(Output_built_in, 'built-in', 'smooth');

[Smoothed95Upper_built_in, Smoothed95Lower_built_in] = ...
    NormalCI(Smoothed_built_in, SmoothedVar_built_in, ConfidenceLevel);
    

% mean and confidence interal
figure;
plot(t, Smoothed_built_in(k,:),...
    t, realFixedEffect,...
    t, Smoothed95Upper_built_in(k,:), '--',...
    t, Smoothed95Lower_built_in(k,:), '--')
legend('Smoothed', 'real fixed effect')
title('Group average: built in')

%% Subject-fit
%  built-in
[YFitted_built_in, YFittedVar_built_in] = ...
    SpaceMeanVar(Output_built_in, SSM_built_in, 'built-in', 'smooth');

[YFitted95Upper_built_in, YFitted95Lower_built_in] = ...
    NormalCI(YFitted_built_in, YFittedVar_built_in, ConfidenceLevel);

%  mean and confidence interval
for n_i = 1:n
    figure;
    plot(t, YFitted_built_in(n_i, :),...
        t, Y(n_i,:),...
        t, realY(n_i,:),...
        t, YFitted95Upper_built_in(n_i, :), '--',...
        t, YFitted95Lower_built_in(n_i, :), '--')
    legend('Fitted', 'Observation', 'Real')
    title(strcat('Subject fit: built in n=', num2str(n_i)))
end