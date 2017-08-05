function [logparahat, fval] = fmeTraining(Algo, Y, fixedArray, randomArray, t, logpara0, diffusePrior)
%fmeTraining computes the MLEs
% Description:
%
% estimate logpara by minimizing the negative log-likelihood value.
%
% Input Arguments:
%   
%   Algo - @BuiltIn / @KalmanAll / @DSS2Step / @DSSFull
%   Y - n-by-T
%   fixedArray - array for fixed effects
%   randomArray - array for random effects
%   t - time points, 1-by-T
%   logpara: parameters for functional mixed effect model
%   diffusePrior: a large value for diffusing prior
%
% Output Arguments:
%
%   logparahat - MLEs of logpara
%   fval - minimized negative log-likelihood value

    Obj = @(logpara) ...
    NlogLik(Algo, Y, fixedArray, randomArray, t, logpara, diffusePrior);

    [logparahat, fval] = fminsearch(Obj, logpara0);
end

