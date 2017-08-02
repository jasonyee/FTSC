function NlogLik = NlogLik(Algo, Y, fixedArray, randomArray, t, logpara, diffusePrior)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    [nSubj, ~] = size(Y);
    SSM = fme2ss(nSubj, fixedArray, randomArray, t, logpara, diffusePrior);
    NlogLik = - Algo(SSM, Y);
    
end

