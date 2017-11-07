function Posterior = BayesUpdate(Prior, CondProb)
%BayesUpdate computes the posterior probability using Bayes formula
% Description:
%
% p(A1|B) = p(A1)p(B|A1) / [p(A1)p(B|A1) + ... + p(Ak)p(B|Ak)]
%
% Input Arguments:
%
%   Prior - a n-by-k matrix, each column is a partition of event B:
%           p(A1),...,p(Ak)
%   CondProb - a n-by-k matrix, each column: p(B|A1),...,p(B|Ak)
%
% Output Arguments:
%
%   Posterior - a n-by-k matrix, each column is the posterior probability:
%           p(A1|B), ..., p(Ak|B)
    
    % get dimensions
    [~, k] = size(Prior);
    
    % p(A1, B), ..., p(Ak, B)
    numerator = Prior .* CondProb;
    
    % p(B), ..., p(B)
    denominator = numerator * ones(k);
    
    % conditional probability formula
    Posterior = numerator ./ denominator;

end

