function NegativeLogLik = NlogLik(Y, t, logpara, diffusePrior)
%NlogLik compute the negative loglik of Y given the FuncMixModel
%   FuncMixModel is a SSM structure

[nSubj, ~] = size(Y);

% cubic spline (F), sin prior (R)
SSM = fmeRandomSinPrior(nSubj, t, logpara, diffusePrior);

% computing negative log-lik
NegativeLogLik= - KalmanAll(SSM, Y);

end

