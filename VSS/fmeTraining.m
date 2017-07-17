%% fmeTraining
%  fmeTraining returns the MLEs of the functional mixed effect model
%  given the data

function logparahat = fmeTraining(dataset, obtime, logpara0, diffusePrior)
%Input:
%   -dataset: (i,t) is the data for patient i at observation t.
%   -obtime: (t) is the time at observation t.
%   -logpara0: initial para for the optimization process.
%   -diffusePrior: the diffuse prior parameter.
%Output:
%   -logparahat: MLEs of the functional mixed effect model

    [n, T] = size(dataset);
    p = 1;                                        % # of fixed effects
    q = 1;                                        % # of random effects
    fixedDesign = repmat(ones(n,p),[1, 1, T]);    % n-by-p-by-T
    randomDesign = repmat(ones(n,q),[1, 1, T]);   % n-by-q-by-T

    NlogLik_vss = @(logpara) ...
    fme2KF(dataset, fixedDesign, randomDesign, obtime, logpara, diffusePrior, true);

    logparahat = fminsearch(NlogLik_vss, logpara0);

end