%% fmeCondProb  [NOT COMPLETED]
%  fmeCondProb returns the density of a new subject
%  conditioning on the cluster in the functional mixed effect model

function CondProb = fmeCondProb(ClusterData, subdata, t, fixedDesign, randomDesign,...
                        subMeasMX, subObseCov, logparahat, diffusePrior)
%Input: t=1:T
%   -ClusterData: (i,t) is the data of group member i at observation t.
%   -subdata: (t) is the data of new subject at observation t.
%   -fixedDesign: (:,:,t) is the fixed design matrix at observation t.
%   -randomDesign: (:,:,t) is the random design matrix at observation t.
%   -subMeasMX: (:,:,t) is the measurement sensitivity matrix of the new subject.
%   -subObseCov: (:,:,t) is the observation innovance covariance matrix of the new subject.
%   -logparahat: the MLE for the cluster.
%Output:
%   -CondProb: the density of a new subject conditioning on this cluster.

    %% Fitting the cluster
    [~, ~, prior] = fme2dss(ClusterData, fixedDesign, ...
                                randomDesign, t, logparahat, diffusePrior);
    %% Computing the conditional prob
    CondProb = dssCondProb(subdata, prior, subMeasMX, subObseCov);
end