function NlogLik = NlogLik_UBC(Y, fixedArray, randomArray, t, logpara, diffusePrior)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
    [nSubj, T] = size(Y);
    SSM = fme2ss(nSubj, fixedArray, randomArray, t, logpara, diffusePrior);
    [~, ~, ~, logLik] = kalman_filter(Y, SSM.TranMX, SSM.MeasMX,...
        SSM.DistCov, SSM.ObseCov, SSM.StateMean0, SSM.StateCov0, 'model', 1:T);
    NlogLik = -logLik;
end

