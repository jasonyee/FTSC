function demo_clustering(struct_file, Options)
%DEMO_CLUSTERING shows the:
%   1. Running time;
%   2. Switch plot;
%   3. Spaghetti plot for group-average fit
%   4. Subject-level fit
%
%Input:
%   -struct_file: stores the MAT-file data in a struct
%   -Options: stores the information for the plotting.
%       .runningtime_unit
%       .YVAR_plot
%       .progress_info
%       .random_num
%       .ylabels

%% clustering running time
fprintf('The running time is %.2f', Options.runningtime_unit, '\n', struct_file.clustertime/60)

%% preallocation
% get data in each cluster
ClusterData = ClusteringData(struct_file.dataset, struct_file.ProgressMembers);
% SSMTotal is a cell array of SSM for all batch data
SSM_kalman = cell(1, struct_file.nClusters);

diffusePrior = 1e7;
ConfidenceLevel = 0.95;     % confidence level

%% Switches plot
figure;
plot(struct_file.SwitchHistory);
title(strcat('Swaps in iterations for ', {' '},...
        Options.YVAR_plot, {', '}, ...
        'nClusters=', num2str(struct_file.nClusters)));
    
%% Spaghetti plot with group average fit

GrewPoints = .8 * ones(1,3);

% get scale for dataset
ymin = min(struct_file.dataset(:))-1;
ymax = max(struct_file.dataset(:))+1;

f = figure;
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = strcat('Spaghetti plot for', {' '}, ...
                Options.YVAR_plot, {', '}, ...
                'nClusters=',num2str(struct_file.nClusters)); 
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';
for k=1:struct_file.nClusters
    
    Y = ClusterData{k};
    [n, T] = size(Y);
    t = (1:T)/T;
    
    % Constructing ssm object
    raw_clusterid = struct_file.cluster_id_progress(k);
    SSM_kalman{k} = ...
        fmeRandomSinPriorBuiltIn(n, t, struct_file.logparahat(:,raw_clusterid), diffusePrior);    
    [~, ~, Output] = smooth(SSM_kalman{k}, Y');
    
    [Smoothed, SmoothedVar] =...
        StatesMeanVar(Output, 'built-in', 'smooth');

    [Smoothed95Upper, Smoothed95Lower] = ...
        NormalCI(Smoothed, SmoothedVar, ConfidenceLevel);
    
    if Options.random_num
        Y = datasample(Y, random_num, 'Replace', false);
    end
    
    subplot(1,struct_file.nClusters,k,'Parent',p);
    
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
        ylabel(Options.ylabels); 
    end
    plottitle = strcat(num2str(k-1), ':', Options.progress_info{k}, {', '}, 'n=', num2str(n));
    title(plottitle);
end

%% Subject-fit plotting
nSubj = min([9, min(cellfun('length', struct_file.ProgressMembers))]);

% get scale for dataset
ymin = min(struct_file.dataset(:))-1;
ymax = max(struct_file.dataset(:))+1;

for h=1:struct_file.nClusters
    
    Y = ClusterData{h};
    Members = struct_file.ProgressMembers{h};
    [n, ~] = size(Y);
    
    % Constructing SSM structures for one cluster
    raw_clusterid = struct_file.cluster_id_progress(h);
    SSM_kalman{h} = ...
        fmeRandomSinPriorBuiltIn(n, t, struct_file.logparahat(:,raw_clusterid), diffusePrior);    
    [~, ~, Output_builtin] = smooth(SSM_kalman{h}, Y');
    
    f = figure;
    p = uipanel('Parent',f,'BorderType','none'); 
    p.Title = strcat(Options.YVAR_plot, ': subject-fit in', {' '}, Options.progress_info(h), {' '}, 'group'); 
    p.TitlePosition = 'centertop'; 
    p.FontSize = 12;
    p.FontWeight = 'bold';

    RandomSubjFitBuiltIn(nSubj, Y, Members, SSM_kalman{h}, Output_builtin, [ymin, ymax], p);
end

end

