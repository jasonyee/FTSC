clear;clc;
% Specify data I/O
Path_Data = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\data\';


% Simulation scenario
nSim = 10;
group_size = 100;
var_random = [100, 100, 100];
var_noise = 2;

MAX_LOOP = 20;
logpara0 = [0.5;6;6;-5;0];

file_name = strcat(num2str(nSim), '-', num2str(group_size), '-');
for j=1:length(var_random)
    file_name = strcat(file_name, num2str(var_random(j)), '-');
end
file_name = strcat(file_name, num2str(var_noise));

% loading data
load(strcat(Path_Data, file_name));

FTSC_CRate = zeros(nSim,1);
FTSC_isSeparated = zeros(nSim, 1);
FTSC_cost = zeros(nSim,1);

SwitchHistory = zeros(nSim, MAX_LOOP);
logP = zeros(nClusters*group_size, nClusters, nSim);
logLik = zeros(nSim, nClusters);

para_len = 5;
logpara_hats = zeros(para_len, nClusters, nSim);
ClusterIDs_simu = zeros(group_size*nClusters, nSim);

%% simulation starts
tic;
parfor i=1:nSim
[FTSC_CRate(i), FTSC_isSeparated(i), FTSC_cost(i), ...
    SwitchHistory(i,:), logP(:,:,i), logLik(i,:), ...
    ClusterIDs_simu(:,i), logpara_hats(:,:,i)] = ... 
FTSCSimulation(data(:,:,i), group_size, nClusters, IniClusterIDs_simu(:,i), logpara0, MAX_LOOP);
end
duration = toc;

% save all variables
save(strcat(Path_Data, file_name, '.mat'));