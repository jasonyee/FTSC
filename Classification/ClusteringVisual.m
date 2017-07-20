%% ClusteringVisual
%  ClusteringVisual presents the plot for each cluster horizontally

function ClusteringVisual(dataset, ClusterData, t)
%Input:
%   -dataset: all batch data.
%   -ClusterData: {k} is the data in cluster k.
%   -t: the common observation time.

    nClusters = length(ClusterData);
    % common axes
    ymax = max(dataset(:));
    ymin = min(dataset(:));
    xmax = max(t);
    xmin = min(t);
    
    figure;
    for k=1:nClusters
        [n, ~] = size(ClusterData{k});
        subplot(1,nClusters, k);
        plot(t, ClusterData{k}');
        axis([xmin, xmax, ymin, ymax]);
        PlotTitle = strcat('cluster ', num2str(k), ' ,', num2str(n),' subjects');
        title(PlotTitle);
    end
    
end

