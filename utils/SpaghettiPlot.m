function SpaghettiPlot(data_simu, nSim, nClusters, ClusterMembers, logparahat)
%SPAGHETTIPLOT Generate Spaghetti plot using smoothing
%  if dataset is a matrix, set nSim to be 1

if length(size(data_simu)) > 2
    dataset = data_simu(:,:,nSim);
else
    dataset = data_simu;
end

% get data in each cluster
ClusterData = ClusteringData(dataset, ClusterMembers);
% SSMTotal is a cell array of SSM for all batch data
SSM_kalman = cell(1, nClusters);

diffusePrior = 1e7;
ConfidenceLevel = 0.95;     % confidence level

GrewPoints = .8 * ones(1,3);

% get scale for dataset
ymin = min(dataset(:));
ymax = max(dataset(:));

f = figure;
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = strcat('Spaghetti plot for', {' '}, ...
                'nSim=',num2str(nSim)); 
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
    [~, ~, Output] = smooth(SSM_kalman{k}, Y');
    
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


end

