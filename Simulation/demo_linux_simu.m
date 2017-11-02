clear;clc;

sample_sim = 24;

nSim = 50;
group_size = 100;
var_random = 100;
var_noise = 1;

path_result = 'Y:\Users\Jialin Yi\output\paper simulation\FixNClusters\data\';

load(strcat(path_result, num2str(nSim),'-', num2str(group_size),'-',...
    num2str(var_random),'-', num2str(var_noise), '.mat'));


%% preallocation
dataset = data(:,:,sample_sim);
ClusterMembers = ClusteringMembers(nClusters, ClusterIDs_simu(:,sample_sim));
% get data in each cluster
ClusterData = ClusteringData(dataset, ClusterMembers);
% SSMTotal is a cell array of SSM for all batch data
SSM_kalman = cell(1, nClusters);

diffusePrior = 1e7;
ConfidenceLevel = 0.95;     % confidence level

%% Spaghetti plot with group average fit
GrewPoints = .8 * ones(1,3);

% get scale for dataset
ymin = -10;
ymax = 10;

f = figure;
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = strcat('Spaghetti plot for', {' '}, ...
                'R=',num2str(var_random), {', '}, 'sigma=',num2str(var_noise)); 
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';
for k=1:nClusters
    
    Y = ClusterData{k};
    [n, T] = size(Y);
    t = (1:T)/T;
    
    % Constructing ssm object
    SSM_kalman{k} = ...
        fmeRandomSinPriorBuiltIn(n, t, logpara_hats(:,k,sample_sim), diffusePrior);    
    [~, logLikSmooth, Output] = smooth(SSM_kalman{k}, Y');
    
    [Smoothed, SmoothedVar] =...
        StatesMeanVar(Output, 'built-in', 'smooth');

    [Smoothed95Upper, Smoothed95Lower] = ...
        NormalCI(Smoothed, SmoothedVar, ConfidenceLevel);
    
    subplot(1,nClusters,k,'Parent',p);
    plot(t, Y', 'Color', GrewPoints);
    hold on;
    plot(t, Smoothed(1,:),...
        t, Smoothed95Upper(1,:), '--',...
        t, Smoothed95Lower(1,:), '--');
    hold on;
    plot(t, zeros(1,T),'--');
    hold off;
    ylim([ymin, ymax]);
    plottitle = strcat('Cluster', num2str(k), ' n=', num2str(n));
    title(plottitle);
end
