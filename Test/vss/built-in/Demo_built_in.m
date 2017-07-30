%% Demo for MATLAB's built-in Kalman filter
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
                 
realY = repmat(realFixedEffect, [n,1]) + realRandomEffect;

Y = realY+ sqrt(sigma_e)*randn(n,m);

%% Model setting

fixedArray = ones(1,p);
randomArray = ones(1,q);

%  Optimization
logpara0 = [0;                                    % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                          % log of randomDiag

diffusePrior = 1e7;

fprintf('The starting value for variance of measurement error is %d .\n', exp(logpara0(1)));

fprintf('The starting value for lambda_b is %d .\n', exp(logpara0(2)));

fprintf('The starting value for lambda_a is %d .\n', exp(logpara0(3)));

fprintf('The starting value for sigma^2_1 is %d .\n', exp(logpara0(4)));

fprintf('The starting value for sigma^2_2 is %d .\n', exp(logpara0(5)));

%% Start point
SSM = fme2ss(n, fixedArray, randomArray, t, logpara0, diffusePrior);
logL = logLik_built_in(SSM, Y)

%% Training parameters
tic
logparahat = fmeTraining_built_in(Y, fixedArray, randomArray, t, logpara0, diffusePrior)
toc

fprintf('The estimated variance of measurement error is %d .\n', exp(logparahat(1)));

fprintf('The estimated lambda_b is %d .\n', exp(logparahat(2)));

fprintf('The estimated lambda_a is %d .\n', exp(logparahat(3)));

fprintf('The estimated sigma^2_1 is %d .\n', exp(logparahat(4)));

fprintf('The estimated sigma^2_2 is %d .\n', exp(logparahat(5)));

%% Model fitting
Md = Md_built_in(n, fixedArray, randomArray, t, logparahat, diffusePrior);
data = cell(m, 1);
for j=1:m
    data{j} = Y(:,j);
end
[~, logL_built_in, Output_built_in] = smooth(Md, data);


%% Group-average
k = 1;
SmoothedStates_built_in = zeros(d, m);
SmoothedStatesCov_built_in = zeros(d, m);
for j=1:m
    SmoothedStates_built_in(:,j) = Output_built_in(j).SmoothedStates;
    SmoothedStatesCov_built_in(:,j) = diag(Output_built_in(j).SmoothedStatesCov);
end
SmoothedStates95Upper_built_in = SmoothedStates_built_in + 1.96*sqrt(SmoothedStatesCov_built_in);
SmoothedStates95Lower_built_in = SmoothedStates_built_in - 1.96*sqrt(SmoothedStatesCov_built_in);

figure;
plot(t, SmoothedStates_built_in(k,:),...
    t, realFixedEffect,...
    t, SmoothedStates95Upper_built_in(k,:), '--',...
    t, SmoothedStates95Lower_built_in(k,:), '--')
legend('Smoothed', 'real fixed effect')
title('Group average: built in')

figure;
plot(t, SmoothedStatesCov_built_in(k,:));
title('Group average variance: built in')

    

%% Subject-fit

YFitted_built_in = zeros(n, m);
YFittedCov_built_in = zeros(n, m);
for j=1:m
    YFitted_built_in(:,j) = Y(:,j) - Output_built_in(j).SmoothedObsInnov;
    YFittedCov_built_in(:,j) = diag(Output_built_in(j).SmoothedObsInnovCov);
end
YFitted95Upper_built_in = YFitted_built_in + 1.96*sqrt(YFittedCov_built_in);
YFitted95Lower_built_in = YFitted_built_in - 1.96*sqrt(YFittedCov_built_in);

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