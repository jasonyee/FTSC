%% Demo for my DSSFull (DSS n-step algorithm) using MATLAB's built-in algorithm
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

%% Starting point: Built_in filter
tic;
NlogLik_built_in = NlogLik(@BuiltIn, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
eval_built_in = toc;
fprintf('Built-in: Negative log-likelihood value for the start point is %d \n', NlogLik_built_in);
fprintf('A single evaluation in built-in function takes %d seconds \n', eval_built_in);

%% Starting point: DSSFull
tic;
NlogLik_dssfull = NlogLik(@DSSFull, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
eval_dssfull = toc;
fprintf('DSSFull: Negative log-likelihood value for the start point is %d \n', NlogLik_dssfull);
fprintf('A single evaluation in DSSFull function takes %d seconds.\n', eval_dssfull);

%% Training parameters: Built_in filter

tic;
logparahat_built_in = fmeTraining(@BuiltIn, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
opti_built_in = toc;

fprintf('MLE for built-in function takes %d seconds.\n', opti_built_in);
fprintf('The built-in estimated variance of measurement error is %d .\n', exp(logparahat_built_in(1)));
fprintf('The built-in estimated lambda_b is %d .\n', exp(logparahat_built_in(2)));
fprintf('The built-in estimated lambda_a is %d .\n', exp(logparahat_built_in(3)));
fprintf('The built-in estimated sigma^2_1 is %d .\n', exp(logparahat_built_in(4)));
fprintf('The built-in estimated sigma^2_2 is %d .\n', exp(logparahat_built_in(5)));

%% Training parameters: DSSFull
tic;
logparahat_dssfull = fmeTraining(@DSSFull, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
opti_dssfull = toc;

fprintf('MLE for DSSFull function takes %d seconds.\n', opti_dssfull);
fprintf('The DSSFull estimated variance of measurement error is %d .\n', exp(logparahat_dssfull(1)));
fprintf('The DSSFull estimated lambda_b is %d .\n', exp(logparahat_dssfull(2)));
fprintf('The DSSFull estimated lambda_a is %d .\n', exp(logparahat_dssfull(3)));
fprintf('The DSSFull estimated sigma^2_1 is %d .\n', exp(logparahat_dssfull(4)));
fprintf('The DSSFull estimated sigma^2_2 is %d .\n', exp(logparahat_dssfull(5)));

%% Model fitting: Built_in smoother

SSM_built_in = fme2ss(n, fixedArray, randomArray, t, logparahat_built_in, diffusePrior);

[logL_built_in, Output_built_in] = BuiltInSmoother(SSM_built_in, Y);

fprintf('The built-in maximized log-likelihood is %d .\n', logL_built_in);

%% Model fitting: DSSFull

SSM_dssfull = fme2ss(n, fixedArray, randomArray, t, logparahat_dssfull, diffusePrior);

[logL_dssfull, Output_dssfull] = DSSFull(SSM_dssfull, Y);

fprintf('The DSSFull maximized log-likelihood is %d .\n', logL_dssfull);

%% Group-average
k = 1;  %  the real fixed effect state parameter
ConfidenceLevel = 0.95;     % confidence level

%  built-in
[Smoothed_built_in, SmoothedVar_built_in] =...
    StatesMeanVar(Output_built_in, 'built-in', 'smooth');

[Smoothed95Upper_built_in, Smoothed95Lower_built_in] = ...
    NormalCI(Smoothed_built_in, SmoothedVar_built_in, ConfidenceLevel);

%  DSSFull
[Smoothed_dssfull, SmoothedVar_dssfull] =...
    StatesMeanVar(Output_dssfull, 'dss-full', 'smooth');

[Smoothed95Upper_dssfull, Smoothed95Lower_dssfull] = ...
    NormalCI(Smoothed_dssfull, SmoothedVar_dssfull, ConfidenceLevel);


% mean and confidence interal
for i=1:n
    figure;
    Smoothed_dssfull_i = reshape(Smoothed_dssfull(k,:,i), 1, m);
    Smoothed95Upper_dssfull_i = reshape(Smoothed95Upper_dssfull(k,:,i), 1, m);
    Smoothed95Lower_dssfull_i = reshape(Smoothed95Lower_dssfull(k,:,i), 1, m);
    plot(t, Smoothed_built_in(k,:),...
        t, Smoothed_dssfull_i,...
        t, realFixedEffect,...
        t, Smoothed95Upper_built_in(k,:), ':',...
        t, Smoothed95Lower_built_in(k,:), ':',...
        t, Smoothed95Upper_dssfull_i, '--',...
        t, Smoothed95Lower_dssfull_i, '--')
    legend('MATLAB with :', 'DSSFull with --', 'real fixed effect')
    tit = strcat('Group average: DSSFull at step ', num2str(i));
    title(tit)
end

% variance
for i=1:n
    figure;
    SmoothedVar_dssfull_i = reshape(SmoothedVar_dssfull(k,:,i), 1, m);
    plot(t, SmoothedVar_built_in(k,:),...
        t, SmoothedVar_dssfull_i);
    legend('MATLAB', 'DSSFull');
    tit = strcat('Group average variance: DSSFull at step ', num2str(i));
    title(tit)
end

%% Subject-fit
%  built-in
[YFitted_built_in, YFittedVar_built_in] = ...
    SpaceMeanVar(Output_built_in, SSM_built_in, 'built-in', 'smooth');

[YFitted95Upper_built_in, YFitted95Lower_built_in] = ...
    NormalCI(YFitted_built_in, YFittedVar_built_in, ConfidenceLevel);

%  dss-full
[YFitted_dssfull, YFittedVar_dssfull] = ...
    SpaceMeanVar(Output_dssfull, SSM_dssfull, 'dss-full', 'smooth');

[YFitted95Upper_dssfull, YFitted95Lower_dssfull] = ...
    NormalCI(YFitted_dssfull, YFittedVar_dssfull, ConfidenceLevel);


%  mean and confidence interval
for n_i = 1:n
    figure;
    subplot(1,2,1);
    plot(t, YFitted_built_in(n_i, :),...
        t, Y(n_i,:),...
        t, realY(n_i,:),...
        t, YFitted95Upper_built_in(n_i, :), '--',...
        t, YFitted95Lower_built_in(n_i, :), '--')
    legend('Fitted', 'Observation', 'Real')
    title(strcat('Subject fit: built in n=', num2str(n_i)))
    
    subplot(1,2,2);
    plot(t, YFitted_dssfull(n_i, :),...
        t, Y(n_i,:),...
        t, realY(n_i,:),...
        t, YFitted95Upper_dssfull(n_i, :), '--',...
        t, YFitted95Lower_dssfull(n_i, :), '--')
    legend('Fitted', 'Observation', 'Real')
    title(strcat('Subject fit: DSSFull(converged) n=', num2str(n_i)))
end

%% Tesing
fprintf('-Group average: \n');
fprintf('MATLAB group mean at t=1 is %5.4f \n', Smoothed_built_in(1,1));
fprintf('MATLAB group var at t=1 is %5.4f \n', SmoothedVar_built_in(1,1));

fprintf('DSSFull step 1 group mean at t=1 is %5.4f \n', Smoothed_dssfull(1,1,1));
fprintf('DSSFull step 1 group var at t=1 is %5.4f \n', SmoothedVar_dssfull(1,1,1));

fprintf('DSSFull(converged) group mean at t=1 is %5.4f \n', Smoothed_dssfull(1,1,20));
fprintf('DSSFull(converged) group var at t=1 is %5.4f \n', SmoothedVar_dssfull(1,1,20));

fprintf('-Subject fit: \n');
fprintf('MATLAB subject 1 mean at t=1 is %5.4f \n', YFitted_built_in(1,1));
fprintf('MATLAB subject 1 var at t=1 is %5.4f \n', YFittedVar_built_in(1,1));
fprintf('MATLAB subject 20 mean at t=1 is %5.4f \n', YFitted_built_in(20,1));
fprintf('MATLAB subject 20 var at t=1 is %5.4f \n', YFittedVar_built_in(20,1));

fprintf('DSSFull(converged) subject 1 mean at t=1 is %5.4f \n', YFitted_dssfull(1,1));
fprintf('DSSFull(converged) subject 1 var at t=1 is %5.4f \n', YFittedVar_dssfull(1,1));
fprintf('DSSFull(converged) subject 20 mean at t=1 is %5.4f \n', YFitted_dssfull(20,1));
fprintf('DSSFull(converged) subject 20 var at t=1 is %5.4f \n', YFittedVar_dssfull(20,1));




