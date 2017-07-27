%% fmeCondProb
%  fmeCondProb returns the density of a new subject
%  conditioning on the cluster in the functional mixed effect model

function logCondProb = fmeCondProb(ClusterData, subdata, SSM, nFixedEffects, nRandomEffects)
%Input: t=1:T
%   -ClusterData: (i,t) is the data of group member i at observation t.
%   -subdata: (t) is the data of new subject at observation t.
%   -SSM: the corresponding state-space model for ***one specific group*** 
%   and the dimension is for ***all*** subject
%   -nFixedEffects: number of fixed effects
%   -nRandomEffects: number of random effects
%Output:
%   -CondProb: the density of a new subject conditioning on this cluster.

    %  add the new subject to the last
    allData = [ClusterData; subdata];
    [n, ~] = size(allData);
    d = 2*(nFixedEffects + n*nRandomEffects);
    %  fitting dss model
    [KalmanFitCell, ~, ~] = dss_uni2step(SSM.TranMX(1:d, 1:d, :), ...
                                         SSM.DistMean(1:d, :), ...
                                         SSM.DistCov(1:d, 1:d, :), ...
                                         SSM.MeasMX(1:n, 1:d, :), ...
                                         SSM.ObseCov(1:n, 1:n, :), ...
                                         allData, ...
                                         SSM.StateMean0(1:d, :), ...
                                         SSM.StateCov0(1:d, 1:d, :));
    
    logCondProb = KalmanFitCell{end}.loglik;
end