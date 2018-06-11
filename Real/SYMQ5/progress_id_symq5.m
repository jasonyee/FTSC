%% SYMQ5: save the progress id for the variable
%   -FTSC

%% loading clustering result
clear;
clc;

% change Options for different clustering result
Options = 'Model Selection';

yvar = 'symq5';
YVAR_path = 'SYMQ5';
YVAR_plot = 'SYMQ5';

%% Determine [<improve_id>, <stable_id>, <worse_id>] using plot from
% clusterplot

cluster_id_progress = [2, 1, 3];

%% Data I/O: path_result locates the clustering result output by FTSC.
NumC = 3;

path_result = strcat('Y:\Users\Jialin Yi\output\', YVAR_path, '\', Options);

file_path = strcat(path_result, '\', YVAR_path,'_dif_FC_', num2str(NumC),'C.mat');

%% Converts the non-informative ClusterIDs to the 
%  [improved-0, stable-1, worse-2] ProgressIDs and save to the mat file.

load(file_path, 'ClusterIDs');

[ProgressIDs, ProgressMembers] = ProgressID(ClusterIDs, cluster_id_progress, file_path);
