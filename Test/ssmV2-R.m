%% Testing for ssmV2

%%
clear;
clc;

%% Simulation
rng(1);                                       % control the randomness

n = 1;                                       % number of subjects
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

fixedDesign = repmat(ones(n,p),[1, 1, m]);    % n-by-p-by-m
randomDesign = repmat(ones(n,q),[1, 1, m]);   % n-by-q-by-m

%  Optimization
logpara0 = [3;                                      % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         5*ones(2*q,1)];                         % log of randomDiag

SSModelStruc = fme2ssm(fixedDesign, randomDesign, t, logpara0);

SSModel1 = ssm_structure(SSModelStruc);

stateDistMean = cell(1, m);
for j=1:m
    stateDistMean{j} = zeros(d,1);
end

SSModel2 = ssmV2(SSModelStruc.stateTran, ...
                stateDistMean, ...
                SSModelStruc.stateDist, ...
                SSModelStruc.measSens, ...
                SSModelStruc.obseInnov, ...
                SSModelStruc.Mean0, ...
                SSModelStruc.Cov0);


%%
tic
[SmoothedMeanhat1, logL1, output1]= smooth(SSModel1, Y');
toc

fixedEffectMeanhat1 = SmoothedMeanhat1(:,1);

tic
[SmoothedMeanhat2, logL2, output2]= smooth(SSModel2, Y');
toc

fixedEffectMeanhat2 = SmoothedMeanhat1(:,1);

plot(t, fixedEffectMeanhat1, t, fixedEffectMeanhat2);






