function KLD = KL_equal(dataset, nClusters, logP)
%KL_equal returns the Kullback Leibler information distance of clustering 
%   to choose the optimal number of clusters, see Guo and Landis (2017)
%
%   dK = - sum_n ( log(sum_k wk p(Y_i | Y^{(k)-i}, theta_k)) ) /n
%   
%Optimal weights are equal weights over clusters
%
%   wk = 1/K

%Optimal weights are 1/nClusters

% get dimensions
[n, ~] = size(dataset);

% Kullback Leibler information distance 

KLD = -sum(log(sum(exp(logP),2)/nClusters))/n ;

end

