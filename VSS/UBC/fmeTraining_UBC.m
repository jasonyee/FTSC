function logparahat = fmeTraining_UBC(Y, fixedArray, randomArray, t, logpara0, diffusePrior)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    NlogLik = @(logpara) ...
    NlogLik_UBC(Y, fixedArray, randomArray, t, logpara, diffusePrior);

    logparahat = fminsearch(NlogLik, logpara0);
end

