%% Comparasion between VSS and KPVSS
%  The example we used here is the functional mixed effect model.
%  All  the data is simulated.
%%
clear;

%% Simulation
rng(1);                                       % control the randomness

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
                 
Y = repmat(realFixedEffect, [n,1]) + realRandomEffect ... 
    + sqrt(sigma_e)*randn(n,m);

plot(t, Y', t, realFixedEffect, 'r--o');
titleStr = strcat('Raw data (', num2str(n),...
                    ' curves) and real fixed effect (red --o form)');
title(titleStr);

%% Model setting

fixedDesign = repmat(ones(n,p),[1, 1, m]);    % n-by-p-by-m
randomDesign = repmat(ones(n,q),[1, 1, m]);   % n-by-q-by-m

%  Optimization
logpara0 = [3;                                      % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         5*ones(2*q,1)];                         % log of randomDiag

% %% Evaluation: VSS v.s. KPVSS
% 
% SSModel = fme2ssm(fixedDesign, randomDesign, t, logpara0);
% 
% fprintf('========================VSS: Evaluation=======================\n')
% tic
% SmoothedMean_vss = smooth(SSModel, Y');
% toc
% 
% fprintf('========================KPVSS: Evaluation=====================\n')
% tic
% SmoothedMean_KPvss = smooth(SSModel, Y', 'Univariate', true);
% toc
% 
% figure;
% plot(t, SmoothedMean_vss(:,1), t, SmoothedMean_KPvss(:,1));
% legend('VSS: smoothed valuation', 'KPVSS: smoothed valuation');
% title('Evaluation comparasion');

%% Optimization: VSS
fprintf('===========================VSS================================\n')
NegLoglik_vss = @(logpara) fme2ssm_NegLogL(Y, t, logpara, false);
tic
[logparahat_vss, NegLoglikval_vss] = fminsearch(NegLoglik_vss, logpara0);
toc
fprintf('-VSS: Estimate of log-standard deviation is %i\n',...
    logparahat_vss(1));
fprintf('and minimized objective value is %i\n', NegLoglikval_vss);

%% Optimization: KPVSS
fprintf('===========================KPVSS==============================\n')
NegLoglik_KPvss = @(logpara) fme2ssm_NegLogL(Y, t, logpara, true);
tic
[logparahat_KPvss, NegLoglikval_KPvss] = ...
    fminsearch(NegLoglik_KPvss, logpara0);
toc
fprintf('-KPVSS: Estimate of log-standard deviation is %i\n',...
    logparahat_KPvss(1));
fprintf('and minimized objective value is %i\n', NegLoglikval_KPvss);

%% Extracting parameters
%  VSS
SSModelStruc_vss = fme2ssm(fixedDesign, randomDesign, t, logparahat_vss);

SSModel_vss = ssm_structure(SSModelStruc_vss);

[SmoothedMeanhat_vss, logL_vss, output_vss]= smooth(SSModel_vss, Y');

fixedEffectMeanhat_vss = SmoothedMeanhat_vss(:,1);

%  KPVSS
SSModelStruc_KPvss = fme2ssm(fixedDesign, randomDesign, t, logparahat_KPvss);

SSModel_KPvss = ssm_structure(SSModelStruc_KPvss);
          
[SmoothedMeanhat_KPvss, logL_KPvss, output_KPvss]= ...
    smooth(SSModel_KPvss, Y', 'Univariate', true);

fixedEffectMeanhat_KPvss = SmoothedMeanhat_KPvss(:,1);
%% FixedEffect Comparasion plotting
plot(t, fixedEffectMeanhat_vss,...
     t, fixedEffectMeanhat_KPvss);
legend('VSS: smoothed fixed effect', 'KPVSS: smoothed fixed effect');
title('Numerical Optimization Comparasion')
fprintf('===========================VSS================================\n')
fprintf('-VSS: Estimate of log-standard deviation is %.*f\n',...
    4, logparahat_vss(1));
fprintf('and minimized objective value is %i\n', NegLoglikval_vss);
fprintf('===========================KPVSS==============================\n')
fprintf('-KPVSS: Estimate of log-standard deviation is %.*f\n',...
    4, logparahat_KPvss(1));
fprintf('and minimized objective value is %i\n', NegLoglikval_KPvss);