function NegativeLogLik = NlogLikBuiltIn(Y, t, logpara, diffusePrior)
%NlogLikBuiltIn compute the negative loglik of Y given the FuncMixModel
%   FuncMixModel is the MATLAB's built-in model

% % Y is T+2-by-1 cell array
% nSubj = length(Y{1});
% % filtering the states
% Md = fmeCubicSplineRConstBuiltIn(nSubj, t, logpara, diffusePrior);
% [~, logLik, ~] = filter(Md, Y);

% Y is n-by-T array
[nSubj, ~] = size(Y);
Md = fmeRandomSinPriorBuiltIn(nSubj, t, logpara, diffusePrior);
% in MATLAB's built-in filter: T-by-n array is required.
[~, logLik, ~] = filter(Md, Y');

% computing negative log-lik
NegativeLogLik = -logLik;

end

