%%  PAINSEV: Spaghetti plot with ClusterIds
%   change the truth id accordingly when analyzing different simulations
%   -FTSC

%% loading clustering resulss
clear;
clc;

% change Options for different clustering result
Options = 'Model Selection';

yvar = 'painsev';
YVAR_path = 'PAINSEV';
YVAR_plot = 'Pain Severity';

%% Data I/O: path_result locates the clustering result output by FTSC.
NumC = 3;

path_result = strcat('Y:\Users\Jialin Yi\output\', YVAR_path, '\', Options);

file_path = strcat(path_result, '\', YVAR_path,'_dif_FC_', num2str(NumC),'C.mat');

cluster_struct = load(file_path);
%% Plotting

ClusterPlot(cluster_struct, YVAR_plot)
