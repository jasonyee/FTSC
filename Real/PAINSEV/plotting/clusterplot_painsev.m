%%  PAINSEV: Spaghetti plot with ClusterIds
%   change the truth id accordingly when analyzing different simulations
%   -FTSC

%% loading clustering resulss
clear;
clc;

Options = 'AllinOne';

yvar = 'painsev';
YVAR_path = 'PAINSEV';
YVAR_plot = 'Pain Severity';

%% Data I/O: path_result locates the clustering result output by FTSC.
NumC = 3;

path_result = strcat('Y:\Users\Jialin Yi\output\', YVAR_path, '\', Options);

load(strcat(path_result, '\', YVAR_path,'_dif_FC_', num2str(NumC),'C.mat'));

%% clustering running time
fprintf('The clustering algorithm running time is %.2f minutes.\n', clustertime/60)

%% preallocation
% get data in each cluster
ClusterData = ClusteringData(dataset, ClusterMembers);
% SSMTotal is a cell array of SSM for all batch data
SSM_kalman = cell(1, nClusters);

diffusePrior = 1e7;
ConfidenceLevel = 0.95;     % confidence level
    
%% Spaghetti plot with group average fit
random_num = 0;

GrewPoints = .8 * ones(1,3);

% get scale for dataset
ymin = min(dataset(:))-1;
ymax = max(dataset(:))+1;

f = figure;
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = strcat('Raw-ClusterIDs plot for', {' '}, ...
                YVAR_plot, {', '}, ...
                'nClusters=',num2str(nClusters)); 
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';
for k=1:nClusters
    
    Y = ClusterData{k};
    [n, T] = size(Y);
    t = (1:T)/T;
    
    % Constructing ssm object
    SSM_kalman{k} = ...
        fmeRandomSinPriorBuiltIn(n, t, logparahat(:,k), diffusePrior);    
    [~, logLikSmooth, Output] = smooth(SSM_kalman{k}, Y');
    
    [Smoothed, SmoothedVar] =...
        StatesMeanVar(Output, 'built-in', 'smooth');

    [Smoothed95Upper, Smoothed95Lower] = ...
        NormalCI(Smoothed, SmoothedVar, ConfidenceLevel);
    
    if random_num
        Y = datasample(Y, random_num, 'Replace', false);
    end
    
    subplot(1,nClusters,k,'Parent',p);
    
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
