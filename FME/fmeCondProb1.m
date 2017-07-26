%% fmeCondProb
%  fmeCondProb returns the density of a new subject
%  conditioning on the cluster in the functional mixed effect model

function logCondProb = fmeCondProb1(ClusterData, subdata, SSM)
%Input: t=1:T
%   -ClusterData: (i,t) is the data of group member i at observation t.
%   -subdata: (t) is the data of new subject at observation t.
%   -SSM: the corresponding state-space model for logparahat and the
%   dimension is for *****nCluster+1***** subject
%Output:
%   -CondProb: the density of a new subject conditioning on this cluster.

    %  add the new subject to the last
    allData = [ClusterData; subdata];
    %  fitting dss model
    [KalmanFitCell, ~, ~] = dss_uni2step(SSM.TranMX, SSM.DistMean, SSM.DistCov, ...
        SSM.MeasMX, SSM.ObseCov, allData, SSM.StateMean0, SSM.StateCov0);
    
    logCondProb = KalmanFitCell{end}.loglik;
end