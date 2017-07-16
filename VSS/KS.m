%% KS
%  KS returns a Kalman smoothing structure.

function KalmanFit = ...
    KS(TranMX, DistMean, DistCov, MeasMX, ObseCov, data, StateMean0, StateCov0)
%Input: t=1:T
%   -TranMX(:,:,t): the state transtion matix from t-1 to t.
%   -DistMean(:,t): the state disturbing mean at t.
%   -DistCov(:,:,t): the state disturbing covariance matrix from t-1 to t.
%   -MeasMX(:,:,t): the measurement matrix at t.
%   -ObseCov(:,:,t): the observation innovation covariance matrix at t.
%   -data(:,t) the dependent data at t.
%Output: KalmanFit is a structure, for t=1:T
%   -loglik: log-likelihood of dependent data 1:T
%   -ForecastedMean: E(x_t|1:t-1)
%   -ForecastedCov: Cov(x_t|1:t-1)
%   -FilteredMean: E(x_t|1:t)
%   -FilteredCov: Cov(x_t|1:t)
%   -SmoothedMean: E(x_t|1:T)
%   -SmoothedCov: Cov(x_t|1:T)
%   -C0: C(0) saved for dynamic state space model

    
    [n,d,T] = size(MeasMX);
    SmoothedMean = zeros(d, T);
    SmoothedCov = zeros(d,d,T);

    KFFit=KF(TranMX, DistMean, DistCov, MeasMX, ObseCov, ...
        data, StateMean0, StateCov0, false);
    
    SmoothedMean(:,T) = KFFit.FilteredMean(:,T);
    SmoothedCov(:,:,T) = KFFit.FilteredCov(:,:,T);
    
    for t=T-1:-1:1
        [SmoothedMean(:,t), SmoothedCov(:,:,t)] = ...
    KSUpdate(TranMX(:,:,t+1), ...
            KFFit.FilteredMean(:,t), KFFit.FilteredCov(:,:,t), ...
            KFFit.ForecastedMean(:,t+1), KFFit.ForecastedCov(:,:,t+1),...
            SmoothedMean(:,t+1), SmoothedCov(:,:,t+1));
    end
    
    KalmanFit.loglik = KFFit.loglik;
    KalmanFit.ForecastedMean = KFFit.ForecastedMean;
    KalmanFit.ForecastedCov = KFFit.ForecastedCov;
    KalmanFit.FilteredMean = KFFit.FilteredMean;
    KalmanFit.FilteredCov = KFFit.FilteredCov;
    KalmanFit.SmoothedMean = SmoothedMean;
    KalmanFit.SmoothedCov = SmoothedCov;
    KalmanFit.C0 = StateCov0*TranMX(:,:,1)'/KFFit.ForecastedCov(:,:,1);

end