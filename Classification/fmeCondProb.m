%% CondProb
%  CondProb returns the density of a new subject
%  conditioning on the cluster in the functional mixed effect model

function logCondProb = fmeCondProb(Algo, ClusterData, subdata, SSMTotal, nFixedEffects, nRandomEffects)
%Input: t=1:T
%   -Algo: @DSSFull / @DSS2Step
%   -ClusterData: (i,t) is the data of group member i at observation t.
%   -subdata: (t) is the data of new subject at observation t.
%   -SSMTotal: the total state-space model for all subjects
%   and the dimension is for ***all*** subject
%   -nFixedEffects: number of fixed effects
%   -nRandomEffects: number of random effects
%Output:
%   -CondProb: the density of a new subject conditioning on this cluster.

    %  add the new subject to the last
    allData = [ClusterData; subdata];
    [nSubj, ~] = size(allData);
    d = 2*(nFixedEffects + nSubj * nRandomEffects);
    
    %  construct new SSM
    SSM.TranMX = SSMTotal.TranMX(1:d, 1:d, :);
    SSM.DistMean = SSMTotal.DistMean(1:d, :);
    SSM.DistCov = SSMTotal.DistCov(1:d, 1:d, :);
    SSM.MeasMX = SSMTotal.MeasMX(1:nSubj, 1:d, :);
    SSM.ObseCov = SSMTotal.ObseCov(1:nSubj, 1:nSubj, :);
    SSM.StateMean0 = SSMTotal.StateMean0(1:d, :);
    SSM.StateCov0 = SSMTotal.StateCov0(1:d, 1:d, :);
    
    %  fitting dss model
    [~, KalmanArray] = Algo(SSM, allData);
    
    logCondProb = KalmanArray(end).loglik;
end