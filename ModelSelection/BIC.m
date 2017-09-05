function BIC = BIC(loglik, logparahat, n)
%BIC returns the Bayesian information criterion of clustering 
%   to choose the optimal number of clusters, see Guo and Landis (2017)
%
%   BIC = log(n)*M - 2 * logP(Y_1,...,Y_n|theta^, M)
%   
%In functional clustering with nClusters = K
%   
%   n = nSubj
%   M = 5*K
%   logP(Y_1,...,Y_n|theta^, M) = sum_l logP(Y^(l)|theta^_l)
%
% Models with more nClusters will be penalized heavier

% get number of adjustable parameters for each cluster and nClusters
[p, nClusters] = size(logparahat); 

% Bayesian information criterion 

BIC = log(n)*(p*nClusters) - 2*sum(loglik);

end

