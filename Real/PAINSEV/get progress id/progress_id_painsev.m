%% PAINSEV: save the progress id for the variable
%   -FTSC

%% loading clustering result
clear;
clc;

yvar = 'painsev';
YVAR_path = 'PAINSEV';
YVAR_plot = 'Pain Severity';

Options = 'AllinOne';

%% Determine [<improve_id>, <stable_id>, <worse_id>] using plot from
% clusterplot

cluster_id_progress = [3, 1, 2];

%% Data I/O: path_result locates the clustering result output by FTSC.
NumC = 3;

path_result = strcat('Y:\Users\Jialin Yi\output\', YVAR_path, '\', Options);

file_path = strcat(path_result, '\', YVAR_path,'_dif_FC_', num2str(NumC),'C.mat');

%% Converts the non-informative ClusterIDs to the 
%  [improved-0, stable-1, worse-2] ProgressIDs and save to the mat file.

load(file_path, 'ClusterIDs');

ProgressIDs = ProgressID(ClusterIDs, cluster_id_progress, file_path);
