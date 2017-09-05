function AIC = AICC(loglik, logparahat, n)
%AIC_c returns the corrected Akaike information criterion of clustering 
%   to choose the optimal number of clusters, see Guo and Landis (2017)
%
%   AIC_c = 2*M - 2 * logP(Y_1,...,Y_n|theta^, M) + 2 * M(M+1)/(n-M-1)
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
M = p*nClusters;
AIC = 2* (M - sum(loglik)) + 2*M*(M+1)/(n-M-1);

end

