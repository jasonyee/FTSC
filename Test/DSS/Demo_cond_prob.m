%% Test for DSS2Step and DSSFull using MATLAB's built-in algorithm 
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;
rng(1)                                       % control the randomness

%% Simulation: raw data for functional mixed effect model

n = 20;                                       % number of subjects
m = 30;                                       % number of observations
t = (1:m)/m;
p = 1;                                        % # of fixed effects
q = 1;                                        % # of random effects
sigma_e = 1;                                  % variance of white noise

d = 2*(p+n*q);                                % dimension of states

realFixedEffect = 5*sin(2*pi*t);              % p-by-m
realRandomEffect = randn(n,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY = repmat(realFixedEffect, [n,1]) + realRandomEffect;

Y = realY+ sqrt(sigma_e)*randn(n,m);

figure;
plot(t, Y');
title('raw data, fixed effect: 5Sin');

%% Model setting

fixedArray = ones(1,p);
randomArray = ones(1,q);

% Start point
logpara0 = [0;                                    % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                          % log of randomDiag

diffusePrior = 1e7;

%% Training with n-1 subject: get parameters
tic;
[logparahat_built_in, fval_built_in] = fmeTraining(@BuiltIn, Y(1:end-1,:), fixedArray, randomArray, t, logpara0, diffusePrior);
opti_built_in = toc;

fprintf('MLE for built-in function takes %d seconds.\n', opti_built_in);
fprintf('The built-in estimated variance of measurement error is %d .\n', exp(logparahat_built_in(1)));
fprintf('The built-in estimated lambda_b is %d .\n', exp(logparahat_built_in(2)));
fprintf('The built-in estimated lambda_a is %d .\n', exp(logparahat_built_in(3)));
fprintf('The built-in estimated sigma^2_1 is %d .\n', exp(logparahat_built_in(4)));
fprintf('The built-in estimated sigma^2_2 is %d .\n', exp(logparahat_built_in(5)));

%% log conditional probability with n-1 subjects

SSMm1_built_in = fme2ss(n-1, fixedArray, randomArray, t, logparahat_built_in, diffusePrior);

[logLm1_built_in, Outputm1_built_in] = BuiltInSmoother(SSMm1_built_in, Y(1:end-1,:));

fprintf('The built-in log-likelihood for n-1 subjects is %d .\n', logLm1_built_in);

%% log conditional probability with n subjects

SSMTotal_built_in = fme2ss(n, fixedArray, randomArray, t, logparahat_built_in, diffusePrior);

[logLTotal_built_in, OutputTotal_built_in] = BuiltInSmoother(SSMTotal_built_in, Y);

fprintf('The built-in log-likelihood for n subjects is %d .\n', logLTotal_built_in);

%% Built-In: log conditional probability for the last subject
logLlastSubj_built_in =  logLTotal_built_in - logLm1_built_in;
fprintf('The built-in log-likelihood for the last subjects is %d .\n', logLlastSubj_built_in);


%% DSS2Step: log conditional probability for the last subject
SSMTotal_dss2step = fme2ss(n, fixedArray, randomArray, t, logparahat_built_in, diffusePrior);
logLlastSubj_dss2step = fmeCondProb(@DSS2Step, Y(1:end-1,:), Y(end,:), SSMTotal_dss2step, p, q);
fprintf('The DSS2Step log-likelihood for the last subjects is %d .\n', logLlastSubj_dss2step);

%% DSSFull: log conditional probability for the last subject
SSMTotal_dssfull = fme2ss(n, fixedArray, randomArray, t, logparahat_built_in, diffusePrior);
logLlastSubj_dssfull = fmeCondProb(@DSSFull, Y(1:end-1,:), Y(end,:), SSMTotal_dss2step, p, q);
fprintf('The DSSFull log-likelihood for the last subjects is %d .\n', logLlastSubj_dssfull);
