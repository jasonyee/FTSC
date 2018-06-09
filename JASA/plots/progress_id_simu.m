%%  Simulated data: Spaghetti plot with ClusterIds
%   change the truth id accordingly when analyzing different simulations
%   -FTSC

%% loading clustering resulss
clear;
clc;

nSim = 10;
group_size = 100;
var_random = [200, 100, 100];
var_noise = 2;

experiment = 4;
%% Determine [<improve_id>, <stable_id>, <worse_id>] using plot from
% clusterplot

cluster_id_progress = [1, 3, 2];

file_name = strcat(num2str(nSim), '-', num2str(group_size), '-',...
    num2str(var_random(1)), '-', num2str(var_random(2)), '-',...
    num2str(var_random(3)), '-', num2str(var_noise));

YVAR_plot = 'simulation';


%% Data I/O: path_result locates the clustering result output by FTSC.

path_result = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\data\';

file_path = strcat(path_result, file_name,'.mat');

%% Data I/O: path_result locates the clustering result output by FTSC.

%% Converts the non-informative ClusterIDs to the 
%  [improved-0, stable-1, worse-2] ProgressIDs and save to the mat file.

load(file_path, 'ClusterIDs_simu');
%%
[ProgressIDs, ProgressMembers] = ProgressID(ClusterIDs_simu(:,experiment), cluster_id_progress, file_path);
