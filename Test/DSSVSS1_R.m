%% Testing evalutation of DSS and VSS using fme example.........PASS
%  Adding the following folders to the path:
%   -FTSC
%   -Kalman
%   -KPMstats

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

k = 1;

%% Model fitting
%  DSS
tic
[output_arg_dss, loglik, prior] = fme2dss(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior);
toc

%  KF
tic
output_arg_KF = fme2KF(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior, false);
toc

%  KS
tic
output_arg_KS = fme2KS(Y, fixedDesign, randomDesign, t, logpara0, diffusePrior);
toc


%% Filtering
for i=1:n
    %  DSS
    fixedEffectMeanhat_dss = output_arg_dss{i}.FilteredMean(k,:);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INSERT HERE
    fixedEffectCovhat_dss = reshape(output_arg_dss{i}.FilteredCov(k,k,:), [1, m]);

    %  KF
    fixedEffectMeanhat_KF = output_arg_KF.FilteredMean(k,:);
    fixedEffectCovhat_KF = reshape(output_arg_KF.FilteredCov(k,k,:), [1, m]);


    % Plotting
    figure;
    subplot(1,2,1)
    plot(t, fixedEffectMeanhat_dss, t, fixedEffectMeanhat_KF );
    legend('dss', 'vss');
    plottitle = strcat('Filtered Mean when i=', num2str(i));
    title(plottitle);

    subplot(1,2,2)
    plot(t, fixedEffectCovhat_dss, t, fixedEffectCovhat_KF);
    legend('dss', 'vss');
    plottitle = strcat('Filtered Variance when i=', num2str(i));
    title(plottitle);
end

%% Smoothing
for i=1:n
    %  DSS
    fixedEffectMeanhat_dss = output_arg_dss{i}.SmoothedMean(k,:);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INSERT HERE
    fixedEffectCovhat_dss = reshape(output_arg_dss{i}.SmoothedCov(k,k,:), [1, m]);

    %  KS
    fixedEffectMeanhat_KS = output_arg_KS.SmoothedMean(k, :);
    fixedEffectCovhat_KS = reshape(output_arg_KS.SmoothedCov(k,k,:), [1, m]);

    % Plotting
    figure;
    subplot(1,2,1)
    plot(t, fixedEffectMeanhat_dss, t, fixedEffectMeanhat_KS);
    legend('dss', 'vss');
    plottitle = strcat('Smoothed Mean when i=', num2str(i));
    title(plottitle);
    
    subplot(1,2,2)
    plot(t, fixedEffectCovhat_dss, t, fixedEffectCovhat_KS);
    legend('dss', 'vss');
    plottitle = strcat('Smoothed Variance when i=', num2str(i));
    title(plottitle);
    
end




