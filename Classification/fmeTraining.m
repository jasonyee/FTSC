%% fmeTraining
%  fmeTraining returns the MLEs of the functional mixed effect model
%  given the data

function logparahat = fmeTraining(dataset, obtime, fixedArray, randomArray, logpara0, diffusePrior)
%Input:
%   -dataset: (i,t) is the data for patient i at observation t.
%   -obtime: (t) is the time at observation t.
%   -fixedArray: 1-by-p array stands for fixed effect coefficients.
%   -randomArray: 1-by-q array stands for random effect coefficients.
%   -logpara0: initial para for the optimization process.
%   -diffusePrior: the diffuse prior parameter.
%Output:
%   -logparahat: MLEs of the functional mixed effect model
    
    [n, m] = size(dataset);
    
    fixedDesign = repmat(fixedArray,[n, 1, m]);    % n-by-p-by-m
    randomDesign = repmat(randomArray,[n, 1, m]);   % n-by-q-by-m
    
    NlogLik_vss = @(logpara) ...
    fme2KF(dataset, fixedDesign, randomDesign, obtime, logpara, diffusePrior, true);

    logparahat = fminsearch(NlogLik_vss, logpara0);

end