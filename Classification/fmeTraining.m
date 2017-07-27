%% fmeTraining
%  fmeTraining returns the MLEs of the functional mixed effect model
%  given the data

function logparahat = fmeTraining(dataset, obtime, fixedArray, randomArray, logpara0, diffusePrior)
%Input:
%   -dataset: (i,t) is the data for patient i at observation t.
%   -obtime: (t) is the time at observation t.
%   -fixedArray: 1-by-p array stands for fixed effect factors.
%   -randomArray: 1-by-q array stands for random effect factors.
%   -logpara0: initial para for the optimization process.
%   -diffusePrior: the diffuse prior parameter.
%Output:
%   -logparahat: MLEs of the functional mixed effect model
    
    
    NlogLik_vss = @(logpara) ...
    fme2KF(dataset, fixedArray, randomArray, obtime, logpara, diffusePrior, true);

    logparahat = fminsearch(NlogLik_vss, logpara0);

end