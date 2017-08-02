function [logparahat, fval] = fmeTraining(Algo, Y, fixedArray, randomArray, t, logpara0, diffusePrior)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    Obj = @(logpara) ...
    NlogLik(Algo, Y, fixedArray, randomArray, t, logpara, diffusePrior);

    [logparahat, fval] = fminsearch(Obj, logpara0);
end

