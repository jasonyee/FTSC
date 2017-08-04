%% Demo2 for fmeCondProb
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;
rng(1)                                       % control the randomness

%% Simulation: raw data for functional mixed effect model


m = 30;                                       % number of observations
t = (1:m)/m;
p = 1;                                        % # of fixed effects
q = 1;                                        % # of random effects


nClusters = 2;

% group 1
n1 = 30;                                       % number of subjects
d1 = 2*(p+n1*q);                                % dimension of states

sigma_e1 = 1;                                  % variance of white noise

realFixedEffect1 = 7*sin(2*pi*t);              % p-by-m
realRandomEffect1 = randn(n1,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY1 = repmat(realFixedEffect1, [n1,1]) + realRandomEffect1;

Y1 = realY1+ sqrt(sigma_e1)*randn(n1,m);

% group 2
n2 = 30;                                       % number of subjects
d2 = 2*(p+n2*q);                                % dimension of states

sigma_e2 = 1;                                  % variance of white noise

realFixedEffect2 = 7*sin(2*pi*t+pi/2);              % p-by-m
realRandomEffect2 = randn(n2,4)*[cos(2*pi*t);cos(4*pi*t);...
                               cos(6*pi*t);ones(1,m)];
                 
realY2 = repmat(realFixedEffect2, [n2,1]) + realRandomEffect2;

Y2 = realY2+ sqrt(sigma_e2)*randn(n2,m);

dataset = [Y1; Y2];

realClusterIDs = [ones(n1,1); 2*ones(n2,1)];

realClusterMembers = ClusteringMembers(nClusters, realClusterIDs);
realClusterData = ClusteringData(dataset, realClusterMembers);
ClusteringVisual(dataset, realClusterData, t);


%% Model setting

fixedArray = ones(1,p);
randomArray = ones(1,q);

% Start point
logpara0 = [0;                                    % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                          % log of randomDiag

diffusePrior = 1e7;

%% Starting point: Group 1
% Built_in filter
tic;
NlogLik_built_in_G1 = NlogLik(@BuiltIn, Y1, fixedArray, randomArray, t, logpara0, diffusePrior);
eval_built_in_G1 = toc;
fprintf('Built-in (Group 1): Negative log-likelihood value for the start point is %d \n', NlogLik_built_in_G1);
fprintf('A single evaluation in built-in function takes %d seconds.\n', eval_built_in_G1);

% KalmanAll
tic;
NlogLik_kalman_G1 = NlogLik(@KalmanAll, Y1, fixedArray, randomArray, t, logpara0, diffusePrior);
eval_kalman_G1 = toc;
fprintf('KalmanAll (Group 1): Negative log-likelihood value for the start point is %d \n', NlogLik_kalman_G1);
fprintf('A single evaluation in KalmanAll function takes %d seconds.\n', eval_kalman_G1);

%% Starting point: Group 2
% Built_in filter
tic;
NlogLik_built_in_G2 = NlogLik(@BuiltIn, Y2, fixedArray, randomArray, t, logpara0, diffusePrior);
eval_built_in_G2 = toc;
fprintf('Built-in (Group 2): Negative log-likelihood value for the start point is %d \n', NlogLik_built_in_G2);
fprintf('A single evaluation in built-in function takes %d seconds.\n', eval_built_in_G2);

% KalmanAll
tic;
NlogLik_kalman_G2 = NlogLik(@KalmanAll, Y2, fixedArray, randomArray, t, logpara0, diffusePrior);
eval_kalman_G2 = toc;
fprintf('KalmanAll (Group 2): Negative log-likelihood value for the start point is %d \n', NlogLik_kalman_G2);
fprintf('A single evaluation in KalmanAll function takes %d seconds.\n', eval_kalman_G2);


%% Training parameters: Group 1
tic;
[logparahat_kalman_G1, fval_kalman_G1] = fmeTraining(@KalmanAll, Y1, fixedArray, randomArray, t, logpara0, diffusePrior);
opti_kalman_G1 = toc;

fprintf('MLE (Group 1) for KalmanAll function takes %d seconds.\n', opti_kalman_G1);
fprintf('The KalmanAll estimated variance of measurement error is %d .\n', exp(logparahat_kalman_G1(1)));
fprintf('The KalmanAll estimated lambda_b is %d .\n', exp(logparahat_kalman_G1(2)));
fprintf('The KalmanAll estimated lambda_a is %d .\n', exp(logparahat_kalman_G1(3)));
fprintf('The KalmanAll estimated sigma^2_1 is %d .\n', exp(logparahat_kalman_G1(4)));
fprintf('The KalmanAll estimated sigma^2_2 is %d .\n', exp(logparahat_kalman_G1(5)));

%% Training parameters: Group 2
tic;
[logparahat_kalman_G2, fval_kalman_G2] = fmeTraining(@KalmanAll, Y2, fixedArray, randomArray, t, logpara0, diffusePrior);
opti_kalman_G2 = toc;

fprintf('MLE (Group 2) for KalmanAll function takes %d seconds.\n', opti_kalman_G2);
fprintf('The KalmanAll estimated variance of measurement error is %d .\n', exp(logparahat_kalman_G2(1)));
fprintf('The KalmanAll estimated lambda_b is %d .\n', exp(logparahat_kalman_G2(2)));
fprintf('The KalmanAll estimated lambda_a is %d .\n', exp(logparahat_kalman_G2(3)));
fprintf('The KalmanAll estimated sigma^2_1 is %d .\n', exp(logparahat_kalman_G2(4)));
fprintf('The KalmanAll estimated sigma^2_2 is %d .\n', exp(logparahat_kalman_G2(5)));


%% Model fitting: Group 1

SSM_kalman_G1 = fme2ss(n1, fixedArray, randomArray, t, logparahat_kalman_G1, diffusePrior);

[logL_kalman_G1, Output_kalman_G1] = KalmanAll(SSM_kalman_G1, Y1);

fprintf('The KalmanAll (Group 1) maximized log-likelihood is %d .\n', logL_kalman_G1);

%% Model fitting: Group 2

SSM_kalman_G2 = fme2ss(n2, fixedArray, randomArray, t, logparahat_kalman_G2, diffusePrior);

[logL_kalman_G2, Output_kalman_G2] = KalmanAll(SSM_kalman_G2, Y2);

fprintf('The KalmanAll (Group 2) maximized log-likelihood is %d .\n', logL_kalman_G2);

%% Group-average
k = 1;  %  the real fixed effect state parameter
ConfidenceLevel = 0.95;     % confidence level

%  Group 1
[Smoothed_kalman_G1, SmoothedVar_kalman_G1] =...
    StatesMeanVar(Output_kalman_G1, 'kalman-all', 'smooth');

[Smoothed95Upper_kalman_G1, Smoothed95Lower_kalman_G1] = ...
    NormalCI(Smoothed_kalman_G1, SmoothedVar_kalman_G1, ConfidenceLevel);

%  Group 2
[Smoothed_kalman_G2, SmoothedVar_kalman_G2] =...
    StatesMeanVar(Output_kalman_G2, 'kalman-all', 'smooth');

[Smoothed95Upper_kalman_G2, Smoothed95Lower_kalman_G2] = ...
    NormalCI(Smoothed_kalman_G2, SmoothedVar_kalman_G2, ConfidenceLevel);

% mean and confidence interal
figure;
subplot(1,2,1);
plot(t, Smoothed_kalman_G1(k,:),...
    t, realFixedEffect1,...
    t, Smoothed95Upper_kalman_G1(k,:), '--',...
    t, Smoothed95Lower_kalman_G1(k,:), '--')
legend('Smoothed', 'real fixed effect 1')
title('Group average: group 1')
subplot(1,2,2)
plot(t, Smoothed_kalman_G2(k,:),...
    t, realFixedEffect2,...
    t, Smoothed95Upper_kalman_G2(k,:), '--',...
    t, Smoothed95Lower_kalman_G2(k,:), '--')
legend('Smoothed', 'real fixed effect 2')
title('Group average: group 2')

% variance
figure;
subplot(1,2,1);
plot(t, SmoothedVar_kalman_G1(k,:));
title('Group average variance: group 1')
subplot(1,2,2);
plot(t, SmoothedVar_kalman_G2(k,:));
title('Group average variance: group 2')

    

%% Subject-fit

%  group 1
[YFitted_kalman_G1, YFittedVar_kalman_G1] = ...
    SpaceMeanVar(Output_kalman_G1, SSM_kalman_G1, 'kalman-all', 'smooth');

[YFitted95Upper_kalman_G1, YFitted95Lower_kalman_G1] = ...
    NormalCI(YFitted_kalman_G1, YFittedVar_kalman_G1, ConfidenceLevel);

%  group 2
[YFitted_kalman_G2, YFittedVar_kalman_G2] = ...
    SpaceMeanVar(Output_kalman_G2, SSM_kalman_G2, 'kalman-all', 'smooth');

[YFitted95Upper_kalman_G2, YFitted95Lower_kalman_G2] = ...
    NormalCI(YFitted_kalman_G2, YFittedVar_kalman_G2, ConfidenceLevel);

%  mean and confidence interval
for n_i = 1:n1
    figure;
    plot(t, YFitted_kalman_G1(n_i, :),...
        t, Y1(n_i,:),...
        t, realY1(n_i,:),...
        t, YFitted95Upper_kalman_G1(n_i, :), '--',...
        t, YFitted95Lower_kalman_G1(n_i, :), '--')
    legend('Fitted', 'Observation', 'Real')
    title(strcat('Subject fit (Group 1): KalmanAll n=', num2str(n_i)))
end

for n_j = 1:n2
    figure;
    plot(t, YFitted_kalman_G2(n_j, :),...
        t, Y2(n_j,:),...
        t, realY2(n_j,:),...
        t, YFitted95Upper_kalman_G2(n_j, :), '--',...
        t, YFitted95Lower_kalman_G2(n_j, :), '--')
    legend('Fitted', 'Observation', 'Real')
    title(strcat('Subject fit (Group 2): KalmanAll n=', num2str(n_j)))
end


%% New subject

% 7Sins
newSub_7Sin_real = 7 * sin(2*pi*t) + randn(1,4) * ...
    [cos(2*pi*t);cos(4*pi*t);cos(6*pi*t);ones(1,m)];
newSub_7Sin = newSub_7Sin_real + sqrt(sigma_e1)*randn(1,m);   


% 7Sin_shift
newSub_7Sin_shift_real = 7 * sin(2*pi*t + pi/4) + randn(1,4) * ...
    [cos(2*pi*t);cos(4*pi*t);cos(6*pi*t);ones(1,m)];
newSub_7Sin_shift = newSub_7Sin_shift_real + sqrt(sigma_e1)*randn(1,m); 


figure;
subplot(1,2,1)
plot(t, newSub_7Sin_shift,...
     t, newSub_7Sin);
legend('7Sin shift', '7Sin');
title('Observations for 2 new subjects');

subplot(1,2,2)
plot(t, newSub_7Sin_shift_real,...
     t, newSub_7Sin_real);
legend('7Sin shift', '7Sin');
title('Real values for 2 new subjects');


%% log-conditional-probability
clc;
% set algo to compute the conditional probability
Algo = @DSS2Step;

% group 1
SSMTotal = SSM_kalman_G1;

logCondProb_7Sin_G1 = ...
    fmeCondProb(Algo, Y1(1:end-1,:), newSub_7Sin, SSMTotal, 1, 1);
logCondProb_7Sin_shift_G1 = ...
    fmeCondProb(Algo, Y1(1:end-1,:), newSub_7Sin_shift, SSMTotal, 1, 1);
 
fprintf('Using KalmanAll to train parameters (Group 1) and DSS2Step to calculate log conditional probability: \n');
fprintf('-7Sin: %d \n', logCondProb_7Sin_G1);
fprintf('-7Sin_shift: %d \n', logCondProb_7Sin_shift_G1);


% group 2
SSMTotal = SSM_kalman_G2;

logCondProb_7Sin_G2 = ...
    fmeCondProb(Algo, Y1(1:end-1,:), newSub_7Sin, SSMTotal, 1, 1);
logCondProb_7Sin_shift_G2 = ...
    fmeCondProb(Algo, Y1(1:end-1,:), newSub_7Sin_shift, SSMTotal, 1, 1);
 
fprintf('Using KalmanAll to train parameters (Group 2) and DSS2Step to calculate log conditional probability: \n');
fprintf('-7Sin: %d \n', logCondProb_7Sin_G2);
fprintf('-7Sin_shift: %d \n', logCondProb_7Sin_shift_G2);
