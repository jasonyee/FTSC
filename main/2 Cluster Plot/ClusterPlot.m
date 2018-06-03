function ClusterPlot(cluster_struct, YVAR_plot)
%ClusterPlot is the panel plot with the non-informative raw ClusterIDs
%output by FTSC.
%
%Input:
%   -cluster_struct: the struct for mat file saved by FTSC script.
%   -YVAR_plot: the variable name of the dataset

% clustering running time
fprintf('The clustering algorithm running time is %.2f minutes.\n', cluster_struct.clustertime/60)

% preallocation
% get data in each cluster
ClusterData = ClusteringData(cluster_struct.dataset, cluster_struct.ClusterMembers);
% SSMTotal is a cell array of SSM for all batch data
SSM_kalman = cell(1, cluster_struct.nClusters);

diffusePrior = 1e7;
ConfidenceLevel = 0.95;     % confidence level
    
% Spaghetti plot with group average fit
random_num = 0;

GrewPoints = .8 * ones(1,3);

% get scale for dataset
ymin = min(cluster_struct.dataset(:))-1;
ymax = max(cluster_struct.dataset(:))+1;

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
        fmeRandomSinPriorBuiltIn(n, t, cluster_struct.logparahat(:,k), diffusePrior);    
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

end
