%% SF12_MCS data, built-in, cubic spline(F), sin prior(R)
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;

%% Data I/O
yvar = 'SF12_MCS';

path_data = strcat('Y:\Users\Jialin Yi\data\', yvar, '\');

path_result = strcat('Y:\Users\Jialin Yi\output\', yvar, '\Model Selection\');

%% Clustering setting
nCLower = 3;
nCUpper = 3;
dif = nCUpper - nCLower + 1;

%% Clustering setting
MAX_LOOP = 20;
logpara0 = [0.5;6;6;-5;0];

%% 

    
for nClusters = nCLower:nCUpper

    % load data
    load(strcat(path_data, yvar, '_dif_',num2str(nClusters),'C.mat'));
    dataset = yvar_dif;
    IniClusterIDs = WaldClusterID;

    % get time points
    [~, m] = size(dataset);
    t = (1:m)/m;

    % clustering starts
    tic;
    [ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
        SSMBuiltInClustering(dataset, nClusters, IniClusterIDs, logpara0, MAX_LOOP);
    clustertime = toc;

    % convergence of algorithm
    subplot(2, 5, nClusters);
    plot(SwitchHistory)
    title(strcat('Switches when', {' '},...
                yvar, {', '}, ...
                'nClusters=', num2str(nClusters)));

    % save result
    save(strcat(path_result, yvar, '_dif_FC_',num2str(nClusters),'C.mat'));

    ProgressInfo = ['Functional Clustering ', ...
        ': nClusters = ', num2str(nClusters), ' is finised.'];
    display(ProgressInfo); 
end


