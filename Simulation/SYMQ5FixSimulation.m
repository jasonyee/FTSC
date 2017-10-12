clear;clc;
% Simulation scenario
nSim = 100;
load('Y:\Users\Jialin Yi\output\SYMQ5\MATLAB\C3\FixedEffect.mat');
group_size = 20;
var_random = 900;
var_noise = 3;

FixSimulationSeed = @(seed) ...
    FixSimulation(seed, FixedEffect, group_size, var_random, var_noise);

FTSC_CRate = zeros(nSim,1);
FTSC_isSeparated = zeros(nSim, 1);
kmeans_CRate = zeros(nSim, 1);
kmeans_isSeparated = zeros(nSim, 1);

tic;
parfor i=1:nSim
    [FTSC_CRate(i), FTSC_isSeparated(i), ...
        kmeans_CRate(i), kmeans_isSeparated(i)] = feval(FixSimulationSeed, i);
end
duration = toc;

plot([FTSC_CRate, kmeans_CRate]);
legend('FTSC', 'kmeans');
plottitle = strcat('random effect variance = ', {' '}, num2str(var_random), ...
                   ', noise variance = ', {' '}, num2str(var_noise), ...
                   ', group size = ', {' '}, num2str(group_size));
title(plottitle)
%%
boxplot([FTSC_CRate,kmeans_CRate],'Labels',{'FTSC','kmeans'})
title(strcat('boxplot for classification rate when noise variance = ', ...
            {' '}, num2str(var_noise)))