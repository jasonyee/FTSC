function Cov = RepairCov(Cov)
%REPAIRCOV repair covariance matrix caused by numerical issues

% Syntax:
%
%   Cov = repairCov(Cov)
%
% Description:
%
% Numerical problems may cause non-positive-definite of a
% covariance matrix. Simple repair is attempted, but
% costly repair of replacing negative eigenvalues are not.
%
% Input Arguments:
%
%   Cov - a covariance matrix
%
% Output Arguments:
%
%   Cov - a repaired covariance matrix

    % Main diagonal should not be negative
    % otherwise replace the corresponding colunms and rows with zeros.
    negative = diag(Cov) <= 0;
    if any(negative)
        Cov(negative,:) = 0;
        Cov(:,negative) = 0;
    end

    % Correlation should not be larger than one
    % otherwise truncate the elements
    sd = sqrt(diag(Cov));
    UpperBound = sd * sd' + eye(size(Cov));
    BadCorr = abs(Cov) > UpperBound;
    if any(BadCorr(:))
        Cov(BadCorr) = sign(Cov(BadCorr)) .* UpperBound(BadCorr);
    end

    % Covariance matrix should be symmetric
    Cov = 0.5 * (Cov + Cov');
end