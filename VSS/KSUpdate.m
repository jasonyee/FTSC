%% KSUpdate
%  Kalman smoothing backward one step updating

function [PrevMean, PrevCov] = ...
    KSUpdate(TranMX, FilteredMean, FilteredCov, MeanPred, CovPred,  NextMean, NextCov)
%Input: t=0:T-1
%   -TranMX: the state transtion matix from t to t+1.
%   -FilteredMean: the state disturbing mean at t, E(x_t|1:t).
%   -FilteredCov: the state disturbing covariance matrix at t, Cov(x_t|1:t)
%   -MeanPred: the forecasted states at t+1, E(x_{t+1}|1:t).
%   -CovPred: the forecasted state covariance matrix at t+1, Cov(x_{t+1}|1:t)
%   -NextMean: E(x_{t+1}|1:T).
%   -NextCov: Cov(x_{t+1}|1:T).
%Output: t=0:T-1
%   -PrevMean: E(x_t|1:T).
%   -PrevCov: Cov(x_t|1:T).

    J = FilteredCov*TranMX'/CovPred;
    PrevMean = FilteredMean + J*(NextMean - MeanPred);
    PrevCov = FilteredCov + J*(NextCov - CovPred)*J';
    
end

