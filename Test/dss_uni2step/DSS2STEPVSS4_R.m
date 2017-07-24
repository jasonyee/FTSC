%% Testing random effect of DSS2STEP and VSS using fme example.........PASS
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;

rng(1)                                       % control the randomness

%% ********Testing for the fme example*********


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

fixedDesign = repmat(ones(n,p),[1, 1, m]);    % n-by-p-by-m
randomDesign = repmat(ones(n,q),[1, 1, m]);   % n-by-q-by-m

%  Optimization
logpara0 = [0;                                      % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         1*ones(2*q,1)];                         % log of randomDiag

diffusePrior = 1e7;



%% Optimization
%  DSS
NlogLik_dss = @(logpara) ...
    fme_dss_NlogLik(Y, fixedDesign, randomDesign, t, logpara, diffusePrior);

tic
[logparahat_dss, val_dss] = fminsearch(NlogLik_dss, logpara0);
toc

%%  KF

NlogLik_vss = @(logpara) ...
    fme2KF(Y, fixedDesign, randomDesign, t, logpara, diffusePrior, true);

tic
[logparahat_vss, val_vss] = fminsearch(NlogLik_vss, logpara0);
toc


%% Model fitting
%  DSS
tic
[output_arg_dss, loglik, prior] = fme2dss(Y, fixedDesign, randomDesign, t, logparahat_dss, diffusePrior);
toc

%  KF
tic
output_arg_KF = fme2KF(Y, fixedDesign, randomDesign, t, logparahat_vss, diffusePrior, false);
toc

%  KS
tic
output_arg_KS = fme2KS(Y, fixedDesign, randomDesign, t, logparahat_vss, diffusePrior);
toc

%% Plotting

randomEffectsMeanhat_dss = zeros(n, m);
randomEffectsCovhat_dss = zeros(n, m);

randomEffectsMeanhat_vss = zeros(n, m);
randomEffectsCovhat_vss = zeros(n, m);

for i=1:n
    
    randomEffectsMeanhat_dss(i,:) = output_arg_dss{2}.SmoothedMean(2*i+1,:);
    randomEffectsCovhat_dss(i,:) = reshape(output_arg_dss{2}.SmoothedCov(2*i+1,2*i+1,:) , [1,m]);
    
    randomEffectsMeanhat_vss(i,:) = output_arg_KS.SmoothedMean(2*i+1,:);
    randomEffectsCovhat_vss(i,:) = reshape(output_arg_KS.SmoothedCov(2*i+1,2*i+1,:), [1, m]);
    
    % Plotting
    figure;
    subplot(1,2,1)
    plot(t, randomEffectsMeanhat_dss(i,:), t, randomEffectsMeanhat_vss(i,:), t, realRandomEffect(i,:));
    legend('dss2step', 'vss', 'real');
    plottitle = strcat('Random effect mean when i=', num2str(i));
    title(plottitle);
    
    subplot(1,2,2)
    plot(t, randomEffectsCovhat_dss(i,:), t, randomEffectsCovhat_vss(i,:));
    legend('dss2step', 'vss');
    plottitle = strcat('Random effect variance when i=', num2str(i));
    title(plottitle);
    
end
