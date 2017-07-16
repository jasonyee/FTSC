%% KFUpdate
%  Kalman filtering one step updating

function [MeanPred, CovPred, NextMean, NextCov, loglik] = ...
    KFUpdate(TranMX, DistMean, DistCov, MeasMX, ObseCov, data, PrevMean, PrevCov)
%Input: T>=1
%   -TranMX: the state transtion matix from T-1 to T.
%   -DistMean: the state disturbing mean at T.
%   -DistCov: the state disturbing covariance matrix from T-1 to T.
%   -MeasMX: the measurement matrix at aT.
%   -ObseCov: the observation innovation covariance matrix at T.
%   -data: the dependent data at aT.
%   -PrevMean: a_{T-1|T-1}.
%   -PrevCov: P_{T-1|T-1}.
%Output: T>=1
%   -NextMean: a_{T|T}
%   -NextCov: P_{T|T}
%   -loglik: log-likelihood of dependent data

    MeanPred = TranMX*PrevMean + DistMean;
    CovPred = TranMX*PrevCov*TranMX' + DistCov;
    
    e = data - MeasMX*MeanPred;
    S = MeasMX*CovPred*MeasMX' + ObseCov;
    
    loglik = -0.5*(length(data)*log(2*pi) + log(det(S)) + e'/S*e);
    K = CovPred*MeasMX'/S;
    NextMean = MeanPred + K*e;
    NextCov = CovPred - K*MeasMX*CovPred;
end

