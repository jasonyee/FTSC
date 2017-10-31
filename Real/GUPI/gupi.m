%% GUPI data, built-in, cubic spline(F), sin prior(R)
%  Adding the following folders to the path:
%   -FTSC

%% Clear
clear;
clc;

%% Data I/O

path_data = 'Y:\Users\Jialin Yi\data\GUPI\';

path_result = 'Y:\Users\Jialin Yi\output\GUPI\Model Selection\';

%% Clustering setting
nCLower = 3;
nCUpper = 3;
dif = nCUpper - nCLower + 1;

%% Clustering setting
MAX_LOOP = 20;
logpara0 = [0;2;-5;2;5];

%% 

    
for nClusters = nCLower:nCUpper

    % load data
    load(strcat(path_data, 'GUPI_dif_',num2str(nClusters),'C.mat'));
    dataset = gupi_dif;
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
                'GUPI', {', '}, ...
                'nClusters=', num2str(nClusters)));

    % save result
    save(strcat(path_result, 'GUPI_dif_FC_',num2str(nClusters),'C.mat'));

    ProgressInfo = ['GUPI ', ...
        ': nClusters = ', num2str(nClusters), ' is finised.'];
    display(ProgressInfo);
    
end


