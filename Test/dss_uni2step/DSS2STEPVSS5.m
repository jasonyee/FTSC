%% Testing subject-fit and group-average of DSS2STEP and VSS using fme example.........PASS
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

fixedArray = ones(1, p);
randomArray = ones(1, q);

fixedDesign = repmat(fixedArray,[n, 1, m]);    % n-by-p-by-m
randomDesign = repmat(randomArray,[n, 1, m]);   % n-by-q-by-m

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
    fme2KF(Y, fixedArray, randomArray, t, logpara, diffusePrior, true);

tic
[logparahat_vss, val_vss] = fminsearch(NlogLik_vss, logpara0);
toc

%% Estimation result
estimates_dss=sprintf('%d ', logparahat_dss);
fprintf('-DSS estimate is %s \n', estimates_dss)
fprintf('and the minimized objective value is %i. \n', val_dss);
estimates_vss=sprintf('%d ', logparahat_vss);
fprintf('-VSS estimate is %s \n', estimates_vss)
fprintf('and the minimized objective value is %i. \n', val_vss);


%% Model fitting
%  DSS
tic
[output_arg_dss, loglik, prior] = fme2dss(Y, fixedDesign, randomDesign, t, logparahat_dss, diffusePrior);
toc

%  KF
tic
output_arg_KF = fme2KF(Y, fixedArray, randomArray, t, logparahat_vss, diffusePrior, false);
toc

%  KS
tic
output_arg_KS = fme2KS(Y, fixedDesign, randomDesign, t, logparahat_vss, diffusePrior);
toc


%% Subject-fit
%  dss
subjfitMeanhat_dss = [ output_arg_dss{1}.YFilteredMean(:,:);
                      output_arg_dss{2}.YFilteredMean(1,:) ];
                  
subjfitCovhat_dss = zeros(n, m);
for i=1:n
    if i < n
        subjfitCovhat_dss(i,:) = reshape(output_arg_dss{1}.YFilteredCov(i,i,:), [1, m]);
    else
        subjfitCovhat_dss(i,:) = reshape(output_arg_dss{2}.YFilteredCov(1,1,:), [1, m]);
    end
end

subjfit95Upper_dss = subjfitMeanhat_dss + 1.96*sqrt(subjfitCovhat_dss);
subjfit95Lower_dss = subjfitMeanhat_dss - 1.96*sqrt(subjfitCovhat_dss);

%  vss
subjfitMeanhat_KF = output_arg_KF.YFilteredMean;

subjfitCovhat_KF = zeros(n, m);
for i=1:n
    subjfitCovhat_KF(i,:) = reshape(output_arg_KF.YFilteredCov(i,i,:), [1, m]);
end

subjfit95Upper_KF = subjfitMeanhat_KF + 1.96*sqrt(subjfitCovhat_KF);
subjfit95Lower_KF = subjfitMeanhat_KF - 1.96*sqrt(subjfitCovhat_KF);

for i=1:n
    % Plotting
    figure;
    plot(t, Y(i,:), t, subjfitMeanhat_dss(i,:), t, subjfitMeanhat_KF(i,:),...
        t, subjfit95Upper_dss(i, :), '--',...
        t, subjfit95Upper_KF(i, :), '--',...
        t, subjfit95Lower_dss(i, :), '--',...
        t, subjfit95Lower_KF(i, :), '--');
    legend('true', 'dss', 'vss', ...
           '95Upper_dss',...
           '95Upper_vss',...
           '95Lower_dss',...
           '95Lower_vss');
    plottitle = strcat('Subject-fit when i=', num2str(i));
    title(plottitle);
end




%% Group-average
for i=1:2
    %  DSS
    fixedEffectMeanhat_dss = output_arg_dss{i}.SmoothedMean(k,:);
    fixedEffectCovhat_dss = reshape(output_arg_dss{i}.SmoothedCov(k,k,:), [1, m]);
    fixedEffect95Upper_dss = fixedEffectMeanhat_dss + 1.96*sqrt(fixedEffectCovhat_dss);
    fixedEffect95Lower_dss = fixedEffectMeanhat_dss - 1.96*sqrt(fixedEffectCovhat_dss);

    %  KS
    fixedEffectMeanhat_KS = output_arg_KS.SmoothedMean(k, :);
    fixedEffectCovhat_KS = reshape(output_arg_KS.SmoothedCov(k,k,:), [1, m]);
    fixedEffect95Upper_KS = fixedEffectMeanhat_KS + 1.96*sqrt(fixedEffectCovhat_KS);
    fixedEffect95Lower_KS = fixedEffectMeanhat_KS - 1.96*sqrt(fixedEffectCovhat_KS);
    
    

    % Plotting
    figure;
    plot(t, realFixedEffect, t, fixedEffectMeanhat_dss, t, fixedEffectMeanhat_KS, ...
         t, fixedEffect95Upper_dss, '--', t, fixedEffect95Upper_KS, '--',...
         t, fixedEffect95Lower_dss, '--', t, fixedEffect95Lower_KS, '--');
    legend('real', 'dss', 'vss',...
           '95Upper_dss',...
           '95Upper_vss',...
           '95Lower_dss',...
           '95Lower_vss');
    plottitle = strcat('Group-average when i=', num2str(n-2+i));
    title(plottitle);
end







