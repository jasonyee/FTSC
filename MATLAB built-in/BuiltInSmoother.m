function [logL, Output] = BuiltInSmoother(SSM, Y)
%BUILTINSMOOTHER computes smooth estimates using MATLAB's built-in filter function
% Description:
%
% Convert state-space model structure to MATLAB's ssm object and get
% smoothing estimates
%
% Input Arguments:
%   
%   Information: Y
%   Initial state space model structure: SSM
%
% Output Arguments:
%
%   logLik - log-likelihood for Y(:,:)
%   Output - T-by-1 structure, where element t corresponds to the filtering result at time t.

    Md = ss2BuiltIn(SSM);
    
    [~, T] = size(Y);
    data = cell(T, 1);
    
    for t=1:T
        data{t} = Y(:,t); 
    end
    
    [~, logL, Output] = smooth(Md, data);
end

