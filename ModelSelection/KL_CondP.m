function KLD = KL_CondP(logP)
%KL_CondP returns the Kullback Leibler information distance of clustering 
%   to choose the optimal number of clusters, see Guo and Landis (2017)
%
%   dK = - sum_n ( log(sum_k wk p(Y_i | Y^{(k)-i}, theta_k)) ) /n
%   
%Optimal weights are weights over clusters
%
%   wk = p(Y_i | Y^{(k)-i}, theta_k) / sum_l p(Y_i | Y^{(l)-i}, theta_l)

%More weight are given to the "true" cluster

% get dimensions
[n, ~] = size(logP);

% Kullback Leibler information distance 
logP2 = 2 * logP;

KLD = sum(log(sum(exp(logP),2)) - log(sum(exp(logP2),2)))/n ;

end

