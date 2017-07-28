%% KF
%  KF returns a Kalman filtering structure
%  or the log-likelihood value of the data.

function KFFit = ...
    KF(TranMX, DistMean, DistCov, MeasMX, ObseCov, data, StateMean0, StateCov0)
%Input: t=1:T
%   -TranMX(:,:,t): the state transtion matix from t-1 to t.
%   -DistMean(:,t): the state disturbing mean at t.
%   -DistCov(:,:,t): the state disturbing covariance matrix from t-1 to t.
%   -MeasMX(:,:,t): the measurement matrix at t.
%   -ObseCov(:,:,t): the observation innovation covariance matrix at t.
%   -data(:,t) the dependent data at t.
%   -opti: true when KF is used in the minimization process.
%Output: KFFit is a structure, for t=1:T
%   -ForecastedMean: a_{t|t-1}
%   -ForecastedCov: P_{t|t-1}
%   -FilteredMean: a_{t|t}
%   -FilteredCov: P_{t|t}
%   -loglik: log-likelihood of dependent data 1:T
    
    [~,d,T] = size(MeasMX);
    
    PredictedMean = zeros(d,T);
    PredictedCov = zeros(d,d,T);
    FilteredMean = zeros(d,T);
    FilteredCov = zeros(d,d,T);

    PrevMean = StateMean0;
    PrevCov = StateCov0;
    loglik = .0;
    
    for t=1:T
        if t>1
            PrevMean = FilteredMean(:,t-1);
            PrevCov = FilteredCov(:,:,t-1);
        end
        
        [PredictedMean(:,t), PredictedCov(:,:,t), ...
         FilteredMean(:,t), FilteredCov(:,:,t), Deltaloglik] = ...
        KFUpdate(TranMX(:,:,t), DistMean(:,t), DistCov(:,:,t), ...
            MeasMX(:,:,t), ObseCov(:,:,t), data(:,t), PrevMean, PrevCov);

        loglik = loglik + Deltaloglik;
        
    end
    
    KFFit.loglik = loglik;
    KFFit.PredictedMean = PredictedMean;
    KFFit.PredictedCov = PredictedCov;
    KFFit.FilteredMean = FilteredMean;
    KFFit.FilteredCov = FilteredCov;
        
end