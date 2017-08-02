%% Demo for fmeCondProb
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

% figure;
% plot(t, Y');
% title('raw data, fixed effect: 7Sin');

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


%% Starting point: Built_in filter
tic;
NlogLik_built_in = NlogLik(@BuiltIn, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
eval_built_in = toc;
fprintf('Built-in: Negative log-likelihood value for the start point is %d \n', NlogLik_built_in);
fprintf('A single evaluation in built-in function takes %d seconds.\n', eval_built_in);

%% Starting point: KalmanAll
tic;
NlogLik_kalman = NlogLik(@KalmanAll, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
eval_kalman = toc;
fprintf('KalmanAll: Negative log-likelihood value for the start point is %d \n', NlogLik_kalman);
fprintf('A single evaluation in KalmanAll function takes %d seconds.\n', eval_kalman);

%% Training parameters: Built_in filter

tic;
[logparahat_built_in, fval_built_in] = fmeTraining(@BuiltIn, Y, fixedArray, randomArray, t, logpara0, diffusePrior);
opti_built_in = toc;

fprintf('MLE for built-in function takes %d seconds.\n', opti_built_in);
fprintf('The built-in estimated variance of measurement error is %d .\n', exp(logparahat_built_in(1)));
fprintf('The built-in estimated lambda_b is %d .\n', exp(logparahat_built_in(2)));
fprintf('The built-in estimated lambda_a is %d .\n', exp(logparahat_built_in(3)));
fprintf('The built-in estimated sigma^2_1 is %d .\n', exp(logparahat_built_in(4)));
fprintf('The built-in estimated sigma^2_2 is %d .\n', exp(logparahat_built_in(5)));


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


%% Model fitting: Built_in smoother

SSM_built_in = fme2ss(n, fixedArray, randomArray, t, logparahat_built_in, diffusePrior);

[logL_built_in, Output_built_in] = BuiltInSmoother(SSM_built_in, Y);

fprintf('The built-in maximized log-likelihood is %d .\n', logL_built_in);

%% Model fitting: KalmanAll

SSM_kalman = fme2ss(n, fixedArray, randomArray, t, logparahat_kalman, diffusePrior);

[logL_kalman, Output_kalman] = KalmanAll(SSM_kalman, Y);

fprintf('The KalmanAll maximized log-likelihood is %d .\n', logL_kalman);


%% New subject

% 7Sins
newSub_7Sin_real = realFixedEffect + randn(1,4) *  [cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
newSub_7Sin = newSub_7Sin_real + sqrt(sigma_e)*randn(1,m);   

% 5Sins
newSub_5Sin_real = 5 * sin(2*pi*t) + randn(1,4) * ...
    [cos(2*pi*t);cos(4*pi*t);cos(6*pi*t);ones(1,m)];
newSub_5Sin = newSub_5Sin_real + sqrt(sigma_e)*randn(1,m); 

%% log-conditional-probability

Algo = @DSS2Step;
SSMTotal = SSM_built_in;
%  DSS2Step
logCondProb_7Sin = ...
    fmeCondProb(Algo, Y(1:end-1,:), newSub_7Sin, SSMTotal, 1, 1);



 



