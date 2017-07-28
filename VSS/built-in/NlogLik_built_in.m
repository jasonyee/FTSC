function NlogLik = NlogLik_built_in(Y, fixedArray, randomArray, t, logpara, diffusePrior)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    [nSubj, ~] = size(Y);
    SSM = fme2ss(nSubj, fixedArray, randomArray, t, logpara, diffusePrior);
    NlogLik = -logLik_built_in(SSM, Y);
end

