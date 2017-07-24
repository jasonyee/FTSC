%% fmeCondProb
%  fmeCondProb returns the density of a new subject
%  conditioning on the cluster in the functional mixed effect model

function logCondProb = fmeCondProb(ClusterData, subdata, OBtime, ...
                       fixedArray, randomArray, logparahat, diffusePrior)
%Input: t=1:T
%   -ClusterData: (i,t) is the data of group member i at observation t.
%   -subdata: (t) is the data of new subject at observation t.
%   -OBtime: (t) is the time at observation t.
%   -fixedArray: 1-by-p array stands for fixed effect factors.
%   -randomArray: 1-by-q array stands for random effect factors.
%   -logparahat: the MLE for the cluster.
%Output:
%   -CondProb: the density of a new subject conditioning on this cluster.

    [nCluster, m] = size(ClusterData);
    %  add the new subject to the last
    allData = [ClusterData; subdata];
    allFixedDesign = repmat(fixedArray, [nCluster+1, 1, m]);
    allRandomDesign = repmat(randomArray, [nCluster+1, 1, m]);
    %  fitting the kalman filter and smoother
    [KalmanFitCell, ~, ~] = fme2dss(allData, allFixedDesign, ...
        allRandomDesign, OBtime, logparahat, diffusePrior);
    logCondProb = KalmanFitCell{end}.loglik;
end