function KLD = KL01(logP)
%KL_01 returns the Kullback Leibler information distance of clustering 
%   to choose the optimal number of clusters, see Guo and Landis (2017)
%
%   dK = - sum_n ( log(sum_k wk p(Y_i | Y^{(k)-i}, theta_k)) ) /n
%   
%Optimal weights are weights over clusters
%
%   wk = 1 if i in k, 0 otherwise

% "true" cluster has all the weights

% get dimensions
[n, ~] = size(logP);

% Kullback Leibler information distance 

KLD = -sum(max(logP, [], 2))/n ;

end

