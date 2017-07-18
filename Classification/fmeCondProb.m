%% fmeCondProb  [NOT COMPLETED]
%  fmeCondProb returns the density of a new subject
%  conditioning on the cluster in the functional mixed effect model

function logCondProb = fmeCondProb(ClusterData, subdata, t, ...
                        logparahat, diffusePrior)
%Input: t=1:T
%   -ClusterData: (i,t) is the data of group member i at observation t.
%   -subdata: (t) is the data of new subject at observation t.
%   -subMeasMX: (:,:,t) is the measurement sensitivity matrix of the new subject.
%   -subObseCov: (:,:,t) is the observation innovance covariance matrix of the new subject.
%   -logparahat: the MLE for the cluster.
%Output:
%   -CondProb: the density of a new subject conditioning on this cluster.
    p = 1;  % # of the fixed effects
    q = 1;  % # of the random effects
    [nCluster, m] = size(ClusterData);
    %  add the new subject to the last
    allData = [ClusterData; subdata];
    allFixedDesign = repmat(ones(nCluster+1, p), [1, 1, m]);
    allRandomDesign = repmat(ones(nCluster+1, q), [1, 1, m]);
    %  fitting the kalman filter and smoother
    [KalmanFitCell, ~, ~] = fme2dss(allData, allFixedDesign, ...
        allRandomDesign, t, logparahat, diffusePrior);
    logCondProb = KalmanFitCell{nCluster+1}.loglik;
end