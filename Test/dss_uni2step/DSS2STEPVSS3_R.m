%% Testing subject-fit and group-average of DSS and VSS using fme example.........PASS
%  Adding the following folders to the path:
%   -FTSC
%  Uncomment the subject-fit code in
%   -VSS\KF
%   -VSS\KS
%   see commit: Uncomments for DSSVSS3_R.m
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


%% Subject-fit
for i=1:2
    %  DSS
    if i==1
        subjfitMeanhat_dss = output_arg_dss{i}.YFilteredMean(end,:);
        subjfitCovhat_dss = reshape(output_arg_dss{i}.YFilteredCov(end,end,:), [1, m]);
    else
        subjfitMeanhat_dss = output_arg_dss{i}.YFilteredMean(1,:);
        subjfitCovhat_dss = reshape(output_arg_dss{i}.YFilteredCov(1,1,:), [1, m]);
    end
    %  KF
    subjfitMeanhat_KF = output_arg_KF.YFilteredMean(n-2+i,:);
    subjfitCovhat_KF = reshape(output_arg_KF.YFilteredCov(n-2+i,n-2+i,:), [1, m]);


    % Plotting
    figure;
    subplot(1,2,1)
    plot(t, subjfitMeanhat_dss, t, subjfitMeanhat_KF );
    legend('dss', 'vss');
    plottitle = strcat('Subject-fit mean when i=', num2str(n-2+i));
    title(plottitle);

    subplot(1,2,2)
    plot(t, subjfitCovhat_dss, t, subjfitCovhat_KF);
    legend('dss', 'vss');
    plottitle = strcat('Subject-fit variance when i=', num2str(n-2+i));
    title(plottitle);
end

%% Group-average
for i=1:2
    %  DSS
    fixedEffectMeanhat_dss = output_arg_dss{i}.SmoothedMean(k,:);
    fixedEffectCovhat_dss = reshape(output_arg_dss{i}.SmoothedCov(k,k,:), [1, m]);

    %  KS
    fixedEffectMeanhat_KS = output_arg_KS.SmoothedMean(k, :);
    fixedEffectCovhat_KS = reshape(output_arg_KS.SmoothedCov(k,k,:), [1, m]);

    % Plotting
    figure;
    subplot(1,2,1)
    plot(t, fixedEffectMeanhat_dss, t, fixedEffectMeanhat_KS);
    legend('dss', 'vss');
    plottitle = strcat('Group-average mean when i=', num2str(n-2+i));
    title(plottitle);
    
    subplot(1,2,2)
    plot(t, fixedEffectCovhat_dss, t, fixedEffectCovhat_KS);
    legend('dss', 'vss');
    plottitle = strcat('Group-average variance when i=', num2str(n-2+i));
    title(plottitle);
    
end

%% Estimation result
fprintf('-DSS estimate is %i \n', logparahat_dss(1))
fprintf('and the minimized objective value is %i. \n', val_dss);
fprintf('-VSS estimate is %i \n', logparahat_vss(1))
fprintf('and the minimized objective value is %i. \n', val_vss);






