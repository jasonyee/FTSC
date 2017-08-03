%% Demo for my DSS2Step (DSS 2-step algorithm) using VSS algorithm
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

realFixedEffect = 7*sin(2*pi*t);              % p-by-m
realRandomEffect = randn(n,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY = repmat(realFixedEffect, [n,1]) + realRandomEffect;

Y = realY+ sqrt(sigma_e)*randn(n,m);

figure;
plot(t, Y');
title('raw data, fixed effect: 7Sin');

%% Model setting

fixedArray = ones(1,p);
randomArray = ones(1,q);

% Start point
logpara0 = [0;                                    % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                          % log of randomDiag

diffusePrior = 1e7;

fprintf('The starting value for variance of measurement error is %d .\n', exp(logpara0(1)));

fprintf('The starting value for lambda_b is %d .\n', exp(logpara0(2)));

fprintf('The starting value for lambda_a is %d .\n', exp(logpara0(3)));

fprintf('The starting value for sigma^2_1 is %d .\n', exp(logpara0(4)));

fprintf('The starting value for sigma^2_2 is %d .\n', exp(logpara0(5)));


SSM = fme2ss(n, fixedArray, randomArray, t, logpara0, diffusePrior);

%% Starting point: KalmanAll
tic;
NlogLik_kalman = NlogLik(@KalmanAll, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
eval_kalman = toc;
fprintf('KalmanAll: Negative log-likelihood value for the start point is %d \n', NlogLik_kalman);
fprintf('A single evaluation in KalmanAll function takes %d seconds.\n', eval_kalman);

%% Starting point: DSS2Step
tic;
NlogLik_dss2step = NlogLik(@DSS2Step, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
eval_dss2step = toc;
fprintf('DSS2Step: Negative log-likelihood value for the start point is %d \n', NlogLik_dss2step);
fprintf('A single evaluation in DSS2Step function takes %d seconds.\n', eval_dss2step);

%% Training parameters: KalmanAll
tic;
[logparahat_kalman, fval_kalman] = fmeTraining(@KalmanAll, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
opti_kalman = toc;

fprintf('MLE for KalmanAll function takes %d seconds.\n', opti_kalman);
fprintf('The KalmanAll estimated variance of measurement error is %d .\n', exp(logparahat_kalman(1)));
fprintf('The KalmanAll estimated lambda_b is %d .\n', exp(logparahat_kalman(2)));
fprintf('The KalmanAll estimated lambda_a is %d .\n', exp(logparahat_kalman(3)));
fprintf('The KalmanAll estimated sigma^2_1 is %d .\n', exp(logparahat_kalman(4)));
fprintf('The KalmanAll estimated sigma^2_2 is %d .\n', exp(logparahat_kalman(5)));

%% Training parameters: DSS2Step
tic;
logparahat_dss2step = fmeTraining(@DSS2Step, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
opti_dss2step = toc;

fprintf('MLE for DSS2Step function takes %d seconds.\n', opti_dss2step);
fprintf('The DSS2Step estimated variance of measurement error is %d .\n', exp(logparahat_dss2step(1)));
fprintf('The DSS2Step estimated lambda_b is %d .\n', exp(logparahat_dss2step(2)));
fprintf('The DSS2Step estimated lambda_a is %d .\n', exp(logparahat_dss2step(3)));
fprintf('The DSS2Step estimated sigma^2_1 is %d .\n', exp(logparahat_dss2step(4)));
fprintf('The DSS2Step estimated sigma^2_2 is %d .\n', exp(logparahat_dss2step(5)));

%% Model fitting: KalmanAll

SSM_kalman = fme2ss(n, fixedArray, randomArray, t, logparahat_kalman, diffusePrior);

[logL_kalman, Output_kalman] = KalmanAll(SSM_kalman, Y);

fprintf('The KalmanAll maximized log-likelihood is %d .\n', logL_kalman);
%% Model fitting: DSS2Step

SSM_dss2step = fme2ss(n, fixedArray, randomArray, t, logparahat_dss2step, diffusePrior);

[logL_dss2step, Output_dss2step] = DSS2Step(SSM_dss2step, Y);

fprintf('The DSS2Step maximized log-likelihood is %d .\n', logL_dss2step);

%% Group-average
k = 1;  %  the real fixed effect state parameter
ConfidenceLevel = 0.95;     % confidence level

%  KalmanAll
[Smoothed_kalman, SmoothedVar_kalman] =...
    StatesMeanVar(Output_kalman, 'kalman-all', 'smooth');

[Smoothed95Upper_kalman, Smoothed95Lower_kalman] = ...
    NormalCI(Smoothed_kalman, SmoothedVar_kalman, ConfidenceLevel);

%  dss-2step
[Smoothed_dss2step, SmoothedVar_dss2step] =...
    StatesMeanVar(Output_dss2step, 'dss-2step', 'smooth');

[Smoothed95Upper_dss2step, Smoothed95Lower_dss2step] = ...
    NormalCI(Smoothed_dss2step, SmoothedVar_dss2step, ConfidenceLevel);


% mean and confidence interal
for i=1:2
    figure;
    Smoothed_dss2step_i = reshape(Smoothed_dss2step(k,:,i), 1, m);
    Smoothed95Upper_dss2step_i = reshape(Smoothed95Upper_dss2step(k,:,i), 1, m);
    Smoothed95Lower_dss2step_i = reshape(Smoothed95Lower_dss2step(k,:,i), 1, m);
    plot(t, Smoothed_kalman(k,:),...
        t, Smoothed_dss2step_i,...
        t, realFixedEffect,...
        t, Smoothed95Upper_kalman(k,:), ':',...
        t, Smoothed95Lower_kalman(k,:), ':',...
        t, Smoothed95Upper_dss2step_i, '--',...
        t, Smoothed95Lower_dss2step_i, '--')
    legend('KalmanAll with :', 'DSS2Step with --', 'real fixed effect')
    tit = strcat('Group average: DSS2Step at step ', num2str(i));
    title(tit)
end

% variance
for i=1:2
    figure;
    SmoothedVar_dss2step_i = reshape(SmoothedVar_dss2step(k,:,i), 1, m);
    plot(t, SmoothedVar_kalman(k,:),...
        t, SmoothedVar_dss2step_i);
    legend('KalmanAll', 'DSS2Step');
    tit = strcat('Group average variance: DSS2Step at step ', num2str(i));
    title(tit)
end

%% Subject-fit
%  kalman-all
[YFitted_kalman, YFittedVar_kalman] = ...
    SpaceMeanVar(Output_kalman, SSM_kalman, 'kalman-all', 'smooth');

[YFitted95Upper_kalman, YFitted95Lower_kalman] = ...
    NormalCI(YFitted_kalman, YFittedVar_kalman, ConfidenceLevel);

%  dss-2step
[YFitted_dss2step, YFittedVar_dss2step] = ...
    SpaceMeanVar(Output_dss2step, SSM_dss2step, 'dss-2step', 'smooth');

[YFitted95Upper_dss2step, YFitted95Lower_dss2step] = ...
    NormalCI(YFitted_dss2step, YFittedVar_dss2step, ConfidenceLevel);


%  mean and confidence interval
for n_i = 1:n
    figure;
    subplot(1,2,1);
    plot(t, YFitted_kalman(n_i, :),...
        t, Y(n_i,:),...
        t, realY(n_i,:),...
        t, YFitted95Upper_kalman(n_i, :), '--',...
        t, YFitted95Lower_kalman(n_i, :), '--')
    legend('Fitted', 'Observation', 'Real')
    title(strcat('Subject fit: KalmanAll n=', num2str(n_i)))
    
    subplot(1,2,2);
    plot(t, YFitted_dss2step(n_i, :),...
        t, Y(n_i,:),...
        t, realY(n_i,:),...
        t, YFitted95Upper_dss2step(n_i, :), '--',...
        t, YFitted95Lower_dss2step(n_i, :), '--')
    legend('Fitted', 'Observation', 'Real')
    title(strcat('Subject fit: DSS2Step(converged) n=', num2str(n_i)))
end

%% Tesing
fprintf('-Group average: \n');
fprintf('KalmanAll group mean at t=1 is %5.4f \n', Smoothed_kalman(1,1));
fprintf('KalmanAll group var at t=1 is %5.4f \n', SmoothedVar_kalman(1,1));

fprintf('DSS2Step step 1 group mean at t=1 is %5.4f \n', Smoothed_dss2step(1,1,1));
fprintf('DSS2Step step 1 group var at t=1 is %5.4f \n', SmoothedVar_dss2step(1,1,1));

fprintf('DSS2Step(converged) group mean at t=1 is %5.4f \n', Smoothed_dss2step(1,1,2));
fprintf('DSS2Step(converged) group var at t=1 is %5.4f \n', SmoothedVar_dss2step(1,1,2));

fprintf('-Subject fit: \n');
fprintf('KalmanAll subject 1 mean at t=1 is %5.4f \n', YFitted_kalman(1,1));
fprintf('KalmanAll subject 1 var at t=1 is %5.4f \n', YFittedVar_kalman(1,1));
fprintf('KalmanAll subject 20 mean at t=1 is %5.4f \n', YFitted_kalman(20,1));
fprintf('KalmanAll subject 20 var at t=1 is %5.4f \n', YFittedVar_kalman(20,1));

fprintf('DSS2Step(converged) subject 1 mean at t=1 is %5.4f \n', YFitted_dss2step(1,1));
fprintf('DSS2Step(converged) subject 1 var at t=1 is %5.4f \n', YFittedVar_dss2step(1,1));
fprintf('DSS2Step(converged) subject 20 mean at t=1 is %5.4f \n', YFitted_dss2step(20,1));
fprintf('DSS2Step(converged) subject 20 var at t=1 is %5.4f \n', YFittedVar_dss2step(20,1));





