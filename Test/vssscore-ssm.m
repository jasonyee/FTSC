%% Testing for vsscore and MATLAB's built-in ssm

%%
clear;
clc;

%%


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

% plot(t, Y', t, realFixedEffect, 'r--o');
% titleStr = strcat('Raw data (', num2str(n),...
%                     ' curves) and real fixed effect (red --o form)');
% title(titleStr);


%% Model setting

fixedDesign = repmat(ones(n,p),[1, 1, m]);    % n-by-p-by-m
randomDesign = repmat(ones(n,q),[1, 1, m]);   % n-by-q-by-m

%  Optimization
logpara0 = [3;                                      % log of e  
         -10;-10;                                 % logs of lambdaF, lambdaR
         5*ones(2*q,1)];                         % log of randomDiag

%% Evaluation: vsscore v.s. MATLAB's ssm
fprintf('========================vsscore=======================\n')
tic
output_args = vsscore_fme(Y, fixedDesign, randomDesign, t, logpara0, 100000, false);
toc
fprintf('========================MATLAB=======================\n')
SSModel = ssm_structure(fme2ssm(fixedDesign, randomDesign, t, logpara0));
tic
[SmoothedMean_MATLAB, logL, output_s ]= smooth(SSModel, Y');
toc

%% Smoothed estimates
figure;
subplot(1,2,1);
plot(t, output_args.SmoothedStatesMean(1,:), t, SmoothedMean_MATLAB(:,1));
legend("vsscore","MATLAB");
title("Smoothed.Mean");

subplot(1,2,2);
for j=1:m
    SmoothedStatesCov_vsscore(j) = output_args.SmoothedStatesCov(1,1,j);
    SmoothedStatesCov_MATLAB(j) = output_s(j).SmoothedStatesCov(1,1);
end
plot(t,SmoothedStatesCov_vsscore, t, SmoothedStatesCov_MATLAB);
legend("vsscore","MATLAB");
title("Smoothed.Variance");
