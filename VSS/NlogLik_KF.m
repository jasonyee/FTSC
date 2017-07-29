function NlogLik = NlogLik_KF(Y, fixedArray, randomArray, t, logpara, diffusePrior)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [nSubj, ~] = size(Y);
    SSM = fme2ss(nSubj, fixedArray, randomArray, t, logpara, diffusePrior);
    kalman_filter = KF(SSM.TranMX, SSM.DistMean, SSM.DistCov, SSM.MeasMX,...
        SSM.ObseCov, Y, SSM.StateMean0, SSM.StateCov0);
    NlogLik = -kalman_filter.loglik;

end

