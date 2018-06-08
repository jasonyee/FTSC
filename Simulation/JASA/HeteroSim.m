%% simulation script for FTSC, output data in following name:
%   'nSim-group_size-var_random1-var_random2-var_random3-var_noise.mat'

clear;clc;
% Specify data I/O
Path_FEffect = 'Y:\Users\Jialin Yi\output\SYMQ5\MATLAB\C3\';
Path_OutputData = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\data\';

Path_OutputCRateCurve = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\CRate_curve\';
Path_OutputCRateBoxplot = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\CRate_boxplot\';

Path_OutputBCostCurve = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\BCost_curve\';
Path_OutputBCostBoxplot = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\BCost_boxplot\';

Plot_filetype = '.pdf';

% Simulation scenario
nSim = 10;
group_size = 100;
var_random = [200, 100, 100];
var_noise = 2;

file_name = strcat(num2str(nSim), '-', num2str(group_size), '-');
for j=1:length(var_random)
    file_name = strcat(file_name, num2str(var_random(j)), '-');
end
file_name = strcat(file_name, num2str(var_noise));


% loading data
load(strcat(Path_FEffect, 'FixedEffect.mat'));

% initializing
VarySimulationSeed = @(seed) ...
    VarySimulation(seed, FixedEffect, group_size, var_random, var_noise);

FTSC_CRate = zeros(nSim,1);
FTSC_isSeparated = zeros(nSim, 1);
FTSC_cost = zeros(nSim,1);
kmeans_CRate = zeros(nSim, 1);
kmeans_isSeparated = zeros(nSim, 1);
kmeans_cost = zeros(nSim, 1);

data = repmat(kron(FixedEffect, ones(group_size,1)), 1, 1, nSim);
SampleFixedEffect = zeros(size(data));
RandomEffect = SampleFixedEffect;
WhiteNoise = RandomEffect;

nClusters = size(FixedEffect,1);
para_len = 5;
logpara_hats = zeros(para_len, nClusters, nSim);
ClusterIDs_simu = zeros(group_size*nClusters, nSim);

% simulation starts
tic;
parfor i=1:nSim
    [FTSC_CRate(i), FTSC_isSeparated(i), FTSC_cost(i), ...
        kmeans_CRate(i), kmeans_isSeparated(i), kmeans_cost(i), ...
        data(:,:,i), SampleFixedEffect(:,:,i), RandomEffect(:,:,i), WhiteNoise(:,:,i), ...
        ClusterIDs_simu(:,i),...
        logpara_hats(:,:,i)] = feval(VarySimulationSeed, i*20);
end
duration = toc;

% save all variables
save(strcat(Path_OutputData, file_name, '.mat'));
        
        
%% CRATE

% curve plot
CRateRange = [.4, 1];
CRate__curve = figure('visible', 'off');
plot([FTSC_CRate, kmeans_CRate]);
legend('FTSC', 'kmeans');
ylim(CRateRange);
CRate__plottitle = strcat(' classification rate when ', ...
                   ' noise variance = ', {' '}, num2str(var_noise), ...
                   ', group size = ', {' '}, num2str(group_size));
title(CRate__plottitle)
% save figure
saveas(CRate__curve, strcat(Path_OutputCRateCurve, file_name, Plot_filetype));
close(CRate__curve);

% box plot
CRate__BOXplot = figure('visible', 'off');
boxplot([FTSC_CRate,kmeans_CRate],'Labels',{'FTSC','kmeans'})
ylim(CRateRange)
title(CRate__plottitle);
% save figure
saveas(CRate__BOXplot, strcat(Path_OutputCRateBoxplot, file_name, Plot_filetype));
close(CRate__BOXplot);

%% BCOST

% curve plot
BCostRange = [0, size(data,1)];
BCost__curve = figure('visible', 'off');
plot([FTSC_cost, kmeans_cost]);
legend('FTSC', 'kmeans');
ylim(BCostRange);
BCost__plottitle = strcat(' cost when ', ...
                   ' noise variance = ', {' '}, num2str(var_noise), ...
                   ', group size = ', {' '}, num2str(group_size));
title(BCost__plottitle)
% save figure
saveas(BCost__curve, strcat(Path_OutputBCostCurve, file_name, Plot_filetype));
close(BCost__curve);

% box plot
BCost__BOXplot = figure('visible', 'off');
boxplot([FTSC_cost,kmeans_cost],'Labels',{'FTSC','kmeans'})
ylim(BCostRange)
title(BCost__plottitle);
% save figure
saveas(BCost__BOXplot, strcat(Path_OutputBCostBoxplot, file_name, Plot_filetype));
close(BCost__BOXplot);