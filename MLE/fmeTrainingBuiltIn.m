function [logparahat, logLik] = fmeTrainingBuiltIn(Y, t, logpara0, diffusePrior)
%fmeTrainingBuiltIn computes the MLE of logpara and the maximized loglik
%   options can be set to inspect the optimization process

Obj = @(logpara) ...
    NlogLikBuiltIn(Y, t, logpara, diffusePrior);

%inspect optimization process
% options = optimset('Display','iter','PlotFcns',@optimplotfval);
% 
% [logparahat, fval] = fminsearch(Obj, logpara0, options);

[logparahat, fval] = fminsearch(Obj, logpara0);

logLik = -fval;

end

