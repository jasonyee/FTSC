%% Paper simulation data, built-in, cubic spline(F), sin prior(R)
%  Adding the following folders to the path:
%   -FTSC2

%% Clear
clear;
clc;

%% Data I/O

path_data = 'Y:\Users\Jialin Yi\output\paper simulation\KL\data\';

path_result = 'Y:\Users\Jialin Yi\output\paper simulation\KL\result\';

%% Simulation setting
nSim = 1;
nCLower = 2;
nCUpper = 3;
dif = nCUpper - nCLower + 1;

%% Clustering setting
MAX_LOOP = 20;
logpara0 = [5;10;10;0;0];

clustertime = zeros(nSim, dif);

%% 
count = 1;
for i = 1:nSim
    
    for nClusters = nCLower:nCUpper
        
        % load data
        load(strcat(path_data, 'simu_data_', num2str(nSim),'_',num2str(nClusters),'C.mat'));
        dataset = MissingDt;
        IniClusterIDs = WaldClusterID;

        % get time points
        [~, m] = size(dataset);
        t = (1:m)/m;

        % clustering starts
        tic;
        [ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP] =...
            SSMBuiltInClustering(dataset, nClusters, IniClusterIDs, logpara0, MAX_LOOP);
        clustertime(i, nClusters - nCLower + 1) = toc;

        % convergence of algorithm
        subplot(nSim, dif, count);
        plot(SwitchHistory)
        title(strcat('Switches when', {' '},...
                    'nsim=', num2str(i), ',', {' '},...
                    'nc=', num2str(nClusters)));

        % save result
        save(strcat(path_result, 'simu_result_', num2str(nSim),'_',num2str(nClusters),'C.mat'));
        
        count = count + 1;
    end
end

