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

file_name = strcat(num2str(nSim), '-', num2str(group_size), '-',...
    num2str(var_random(1)), '-', num2str(var_random(2)), '-',...
    num2str(var_random(3)), '-', num2str(var_noise));

YVAR_plot = 'simulation';


%% Data I/O: path_result locates the clustering result output by FTSC.

path_result = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\data\';

file_path = strcat(path_result, file_name,'.mat');

cluster_struct = load(file_path);
%% Plotting

% preallocation
% get data in each cluster
dataset = cluster_struct.data(:,:,experiment);
ClusterMembers = ClusteringMembers(3, cluster_struct.ClusterIDs_simu(:,experiment));
ClusterData = ClusteringData(dataset, ClusterMembers);
% SSMTotal is a cell array of SSM for all batch data
SSM_kalman = cell(1, cluster_struct.nClusters);

diffusePrior = 1e7;
ConfidenceLevel = 0.95;     % confidence level
    
% Spaghetti plot with group average fit
random_num = 0;

GrewPoints = .8 * ones(1,3);

% get scale for dataset
ymin = min(dataset(:))-1;
ymax = max(dataset(:))+1;

f = figure;
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = strcat('Raw-ClusterIDs plot for', {' '}, ...
                YVAR_plot, {', '}, ...
                'nClusters=',num2str(cluster_struct.nClusters)); 
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';
for k=1:cluster_struct.nClusters
    
    Y = ClusterData{k};
    [n, T] = size(Y);
    t = (1:T)/T;
    
    % Constructing ssm object
    SSM_kalman{k} = ...
        fmeRandomSinPriorBuiltIn(n, t, cluster_struct.logpara_hats(:,k,experiment), diffusePrior);    
    [~, ~, Output] = smooth(SSM_kalman{k}, Y');
    
    [Smoothed, SmoothedVar] =...
        StatesMeanVar(Output, 'built-in', 'smooth');

    [Smoothed95Upper, Smoothed95Lower] = ...
        NormalCI(Smoothed, SmoothedVar, ConfidenceLevel);
    
    if random_num
        Y = datasample(Y, random_num, 'Replace', false);
    end
    
    subplot(1,cluster_struct.nClusters,k,'Parent',p);
    
    plot(t, Y', 'Color', GrewPoints);
    hold on;
    plot(t, Smoothed(1,:), 'Color', [0;0;156]/255, 'LineWidth', 1.3)
    plot(t, Smoothed95Upper(1,:), 'LineStyle', '--', 'Color', [192;0;0]/255, 'LineWidth', 0.8)
    plot(t, Smoothed95Lower(1,:), 'LineStyle', '--', 'Color', [192;0;0]/255, 'LineWidth', 0.8);
    hold on;
    plot(t, zeros(1,T),'-- k');
    hold off;
    ylim([ymin, ymax]);
    if k== 1 
        ylabel('Change from Week 4 (vnum = 3)'); 
    end
    plottitle = strcat('Cluster', num2str(k), ' n=', num2str(n));
    title(plottitle);

end