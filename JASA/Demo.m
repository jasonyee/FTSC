clear;clc;
% Simulation scenario
nSim = 10;
group_size = 100;
var_random = [200, 200, 200];
var_noise = 2;

SimID = 3;
LineStyles = {'-', '--', ':'};
LineColors = {[0    0.4470    0.7410],... 
              [0.6350    0.0780    0.1840],...
              'k'};

% loading data set
file_name = strcat(num2str(nSim), '-', num2str(group_size), '-');
for j=1:length(var_random)
    file_name = strcat(file_name, num2str(var_random(j)), '-');
end
file_name = strcat(file_name, num2str(var_noise));

Path_OutputData = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\data\';

dataset = load(strcat(Path_OutputData, file_name, '.mat'));

SignalNoisePlot(dataset, SimID, LineStyles, LineColors)