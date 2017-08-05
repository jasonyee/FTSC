%% fmeCondProb
%  fmeCondProb returns the density of a new subject
%  conditioning on a cluster given a functional mixed effect model

function logCondProb = ...
    fmeCondProb(Algo, ClusterData, subdata, SSMTotal, nFixedEffects, nRandomEffects)
%Input: t=1:T
%   -Algo: @BuiltIn / @KalmanAll / @DSSFull / @DSS2Step
%   -ClusterData: (i,t) is the observation of group member i at time t.
%   -subdata: (t) is the observation of new subject at time t.
%   -SSMTotal: the total state-space model for all subjects over all
%   clusters
%   -nFixedEffects: number of fixed effects
%   -nRandomEffects: number of random effects
%Output:
%   -logCondProb: the log of density for a new subject conditioning on this cluster.

    %  add the new subject to the last
    allData = [ClusterData; subdata];
    [nSubj, ~] = size(allData);
    d = 2*(nFixedEffects + nSubj * nRandomEffects);
    
    %  construct new SSM for allData
    SSM.TranMX = SSMTotal.TranMX(1:d, 1:d, :);
    SSM.DistMean = SSMTotal.DistMean(1:d, :);
    SSM.DistCov = SSMTotal.DistCov(1:d, 1:d, :);
    SSM.MeasMX = SSMTotal.MeasMX(1:nSubj, 1:d, :);
    SSM.ObseCov = SSMTotal.ObseCov(1:nSubj, 1:nSubj, :);
    SSM.StateMean0 = SSMTotal.StateMean0(1:d, :);
    SSM.StateCov0 = SSMTotal.StateCov0(1:d, 1:d, :);
    
    %  calculate log conditional probability
    logCondProb = LogCondProb(Algo, allData, SSM, nFixedEffects, nRandomEffects);
    
end