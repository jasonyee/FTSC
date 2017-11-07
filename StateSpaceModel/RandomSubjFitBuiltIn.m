function RandomSubjFitBuiltIn(nSubj, ClusterData, ClusterMember, SSM, Output, scale, ParentFig)
%RandomSubjBuiltIn randomly picks some subject from dataset to see the subject
%   fit plot
%The subject is choosed without replacement.
%Currently, this function only supports KalmanAll

%Input:
%   -nSubj: random number of subjects to be plotted
%   -ClusterData: data matrix for one cluster
%   -ClusterMember: array of members in this cluster
%   -SSM: state space model structure for this cluster
%   -Output: Kalman structure for this cluster
%   -scale: [ymin, ymax]
%   -ParentFig: the parent figure for subplots



[SpaceMean, SpaceVar] = SpaceMeanVarTimeInvariant(Output, SSM, 'built-in', 'smooth');

[Upper, Lower] = NormalCI(SpaceMean, SpaceVar, 0.95);

[n, T] = size(ClusterData);
t = (1:T)/T;
SampleIndex = datasample(1:n, nSubj, 'Replace', false);

SampleData = ClusterData(SampleIndex,:);
SampleFitMean = SpaceMean(SampleIndex,:);
SampleFitUpper = Upper(SampleIndex,:);
SampleFitLower = Lower(SampleIndex,:);

for j = 1:nSubj
    subplot(3,3,j,'Parent',ParentFig);
    plot(t, SampleData(j,:), 'Color', 'k')
    hold on
    plot(t, SampleFitMean(j,:), 'Color', [0;0;156]/255)
    plot(t, SampleFitUpper(j,:), 'LineStyle', '--', 'Color', [192;0;0]/255)
    plot(t, SampleFitLower(j,:), 'LineStyle', '--', 'Color', [192;0;0]/255)
    hold off
%     legend('raw', 'fitted');
    title(strcat('n=', num2str(ClusterMember(SampleIndex(j)))));
    ylim(scale);
end

end

