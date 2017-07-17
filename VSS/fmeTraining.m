%% fmeTraining
%  fmeTraining returns the MLEs of the functional mixed effect model
%  given the data

function logparahat = fmeTraining(dataset, fixedDesign, randomDesign, obtime, logpara0, diffusePrior)
%Input:
%   -dataset: (i,t) is the data for patient i at observation t.
%   -obtime: (t) is the time at observation t.
%   -fixedDesign: (:,:,t) is the fixed design matrix at observation t
%   -randomDesign: (:,:,t) is the random design matrix at observation t
%   -logpara0: initial para for the optimization process.
%   -diffusePrior: the diffuse prior parameter.
%Output:
%   -logparahat: MLEs of the functional mixed effect model

    NlogLik_vss = @(logpara) ...
    fme2KF(dataset, fixedDesign, randomDesign, obtime, logpara, diffusePrior, true);

    logparahat = fminsearch(NlogLik_vss, logpara0);

end