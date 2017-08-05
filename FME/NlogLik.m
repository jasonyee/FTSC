function NlogLik = NlogLik(Algo, Y, fixedArray, randomArray, t, logpara, diffusePrior)
%NlogLik computes the log-likelihood of Y using different algorithms
% Description:
%
% Convert functional mixed effect model to a state-space model structure.
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
%   NlogLik - negative log-likelihood for Y(:,:)

    [nSubj, ~] = size(Y);
    % state space model for Y(:,:)
    SSM = fme2ss(nSubj, fixedArray, randomArray, t, logpara, diffusePrior);
    NlogLik = - Algo(SSM, Y);
    
end

