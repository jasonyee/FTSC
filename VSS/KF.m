%% KF
%  KF returns a Kalman filtering structure
%  or the log-likelihood value of the data.

function output_arg = ...
    KF(TranMX, DistMean, DistCov, MeasMX, ObseCov, data, StateMean0, StateCov0, opti)
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
    
    [n,d,T] = size(MeasMX);
    ForecastedMean = zeros(d,T);
    ForecastedCov = zeros(d,d,T);
    FilteredMean = zeros(d,T);
    FilteredCov = zeros(d,d,T);
%     %subject-fit
%     YFilteredMean = zeros(n,T);
%     YFilteredCov = zeros(n,n,T);

    PrevMean = StateMean0;
    PrevCov = StateCov0;
    loglik = .0;
    
    for t=1:T
        [ForecastedMean(:,t), ForecastedCov(:,:,t), ...
         PrevMean, PrevCov, Deltaloglik] = ...
        KFUpdate(TranMX(:,:,t), DistMean(:,t), DistCov(:,:,t), ...
            MeasMX(:,:,t), ObseCov(:,:,t), data(:,t), PrevMean, PrevCov);
        FilteredMean(:,t) = PrevMean;
        FilteredCov(:,:,t) = PrevCov;
        loglik = loglik + Deltaloglik;
%         
%         %subject-fit
%         YFilteredMean(:,t) = MeasMX(:,:,t)*FilteredMean(:,t);
%         YFilteredCov(:,:,t) = MeasMX(:,:,t)*FilteredCov(:,:,t)*MeasMX(:,:,t)'+ObseCov(:,:,t);
    end
    
    if opti
        output_arg = -loglik;
        return
    else
        KFFit.loglik = loglik;
        KFFit.ForecastedMean = ForecastedMean;
        KFFit.ForecastedCov = ForecastedCov;
        KFFit.FilteredMean = FilteredMean;
        KFFit.FilteredCov = FilteredCov;
%         
%         %subject-fit
%         KFFit.YFilteredMean = YFilteredMean;
%         KFFit.YFilteredCov = YFilteredCov;
        
        output_arg = KFFit;
    end
end