function [Upper, Lower ] = NormalCI(Mean, Var, ConfidenceLevel )
%NormalCI computes the confidential interval at given confidence level
%   Assume: Mean is an array of means
%           Var is an array of variances
%           CIValue is in [0, 1]
%           This function computes the two-tail bounds

    t = norminv(0.5 * (1+ConfidenceLevel), 0, 1);
    Upper = Mean + t * sqrt(Var);
    Lower = Mean - t * sqrt(Var);

end

