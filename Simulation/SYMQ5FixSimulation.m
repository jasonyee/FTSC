% simulation script for FTSC, output data in following name:
%   'nSim-group_size-var_random-var_noise.mat'

clear;clc;
% Specify data I/O
Path_FEffect = 'Y:\Users\Jialin Yi\output\SYMQ5\MATLAB\C3\';
Path_OutputData = 'Y:\Users\Jialin Yi\output\paper simulation\FixNClusters\data\';
Path_OutputCurve = 'Y:\Users\Jialin Yi\output\paper simulation\FixNClusters\CRate_curve\';
Path_OutputBoxplot = 'Y:\Users\Jialin Yi\output\paper simulation\FixNClusters\CRate_boxplot\';
Plot_filetype = '.pdf';

% Simulation scenario
nSim = 100;
group_size = 20;
var_random = 900;
var_noise = 1;

% loading data
load(strcat(Path_FEffect, 'FixedEffect.mat'));

% initializing
FixSimulationSeed = @(seed) ...
    FixSimulation(seed, FixedEffect, group_size, var_random, var_noise);

FTSC_CRate = zeros(nSim,1);
FTSC_isSeparated = zeros(nSim, 1);
kmeans_CRate = zeros(nSim, 1);
kmeans_isSeparated = zeros(nSim, 1);
data = repmat(kron(FixedEffect, ones(group_size,1)), 1, 1, nSim);

% simulation starts
tic;
parfor i=1:nSim
    [FTSC_CRate(i), FTSC_isSeparated(i), ...
        kmeans_CRate(i), kmeans_isSeparated(i),...
        data(:,:,i)] = feval(FixSimulationSeed, i+1231516);
end
duration = toc;

% save all variables
save(strcat(Path_OutputData, ...
            num2str(nSim), '-', num2str(group_size), '-', ...
            num2str(var_random), '-', num2str(var_noise),...
            '.mat'));



% curve plot
CRateRange = [.4, 1];
curve = figure('visible', 'off');
plot([FTSC_CRate, kmeans_CRate]);
legend('FTSC', 'kmeans');
ylim(CRateRange);
plottitle = strcat(' classification rate when ', ...
                   ' noise variance = ', {' '}, num2str(var_noise), ...
                   ', group size = ', {' '}, num2str(group_size));
title(plottitle)
% save figure
saveas(curve, strcat(Path_OutputCurve, ...
                     num2str(nSim), '-', num2str(group_size), '-', ...
                     num2str(var_random), '-', num2str(var_noise), ...
                     Plot_filetype));
close(curve);

% box plot
BOXplot = figure('visible', 'off');
boxplot([FTSC_CRate,kmeans_CRate],'Labels',{'FTSC','kmeans'})
ylim(CRateRange)
title(plottitle);
% save figure
saveas(BOXplot, strcat(Path_OutputBoxplot, ...
                       num2str(nSim), '-', num2str(group_size), '-', ...
                       num2str(var_random), '-', num2str(var_noise), ...
                       Plot_filetype));
close(BOXplot);