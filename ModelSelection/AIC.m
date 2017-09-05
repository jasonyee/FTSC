function AIC = AIC(loglik, logparahat)
%AIC returns the Akaike information criterion of clustering 
%   to choose the optimal number of clusters, see Guo and Landis (2017)
%
%   AIC = 2*M - 2 * logP(Y_1,...,Y_n|theta^, M)
%   
%In functional clustering with nClusters = K
%   
%   M = 5*K
%   logP(Y_1,...,Y_n|theta^, M) = sum_l logP(Y^(l)|theta^_l)
%
% Models with more nClusters will be penalized heavier

% get number of adjustable parameters for each cluster and nClusters
[p, nClusters] = size(logparahat); 

% Akaike information criterion 

AIC = 2* ((p*nClusters) - sum(loglik));

end

