%%  PAINSEV: Sensitivity analysis, switches plot and random subject fit plotting
%   change the truth id accordingly when analyzing different simulations
%   -FTSC

%% loading clustering result
clear;
clc;

% change Options for different clustering result
Options = 'Model Selection';

yvar = 'painsev';
YVAR_path = 'PAINSEV';
YVAR_plot = 'Pain Severity';

%% K=1 Spaghetti Plot

k1_path = strcat('Y:\Users\Jialin Yi\data\imputation\', yvar, '\');
k1_struct = load(strcat(k1_path, yvar, '_3dif.mat'));

k1Options.title = strcat('Longitudinal', {' '}, YVAR_plot, ': Change from Week 4 (vnum=3)');
k1Options.ylabel = 'Change from vnum=3';
k1Options.xlabel = 'vnum';

demo_uncluster(k1_struct, k1Options)

%% Data I/O
NumC = 3;

path_result = strcat('Y:\Users\Jialin Yi\output\', YVAR_path, '\', Options, '\');

cluster_file = load(strcat(path_result, YVAR_path,'_dif_FC_', num2str(NumC),'C.mat'));

%% Setting options

% Running time
clusterOptions.runningtime_unit = 'minutes';

% Switches plot
clusterOptions.YVAR_plot = YVAR_plot;

% Spaghetti Plot
clusterOptions.progress_info = {'improved', 'stable', 'worse'};
clusterOptions.random_num = 0;
clusterOptions.ylabels = 'Change from Week 4 (vnum = 3)';

%% Demostration
demo_clustering(cluster_file, clusterOptions)



