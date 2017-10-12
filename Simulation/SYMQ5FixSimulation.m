clear;clc;
% Simulation scenario
nSim = 5;
load('Y:\Users\Jialin Yi\output\SYMQ5\MATLAB\C3\FixedEffect.mat');
group_size = 20;
var_random = 3;
var_noise = 3;

FixSimulationSeed = @(seed) ...
    FixSimulation(seed, FixedEffect, group_size, var_random, var_noise);

FTSC_CRate = zeros(nSim,1);
FTSC_isSeparated = zeros(nSim, 1);
kmeans_CRate = zeros(nSim, 1);
kmeans_isSeparated = zeros(nSim, 1);

parfor i=1:nSim
    [FTSC_CRate(i), FTSC_isSeparated(i), ...
        kmeans_CRate(i), kmeans_isSeparated(i)] = feval(FixSimulationSeed, i);
end

plot([FTSC_CRate, kmeans_CRate]);
legend('FTSC', 'kmeans');