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
%   -StateMean0(:): the initial states, t=0.
%   -StateCov0(:,:): the initial states covariance matrix, t=0.

%Output: KalmanFit is a structure, for t=1:T
%   -loglik: log-likelihood of dependent data 1:T
%   -ForecastedMean: E(x_t|1:t-1)
%   -ForecastedCov: Cov(x_t|1:t-1)
%   -FilteredMean: E(x_t|1:t)
%   -FilteredCov: Cov(x_t|1:t)
%   -SmoothedMean: E(x_t|1:T)
%   -SmoothedCov: Cov(x_t|1:T)
%   -Ctp1: C(t-1) saved for dynamic state space model

    
    [~,d,T] = size(MeasMX);
    SmoothedMean = zeros(d, T);
    SmoothedCov = zeros(d,d,T);
    Ctp1 = zeros(d,d,T);

    KFFit=KF(TranMX, DistMean, DistCov, MeasMX, ObseCov, ...
        data, StateMean0, StateCov0, false);
    
    SmoothedMean(:,T) = KFFit.FilteredMean(:,T);
    SmoothedCov(:,:,T) = KFFit.FilteredCov(:,:,T);
    
    for t=T-1:-1:1
        [SmoothedMean(:,t), SmoothedCov(:,:,t), Ctp1(:,:,t+1)] = ...
            KSBackward(TranMX(:,:,t+1), ...
                KFFit.FilteredMean(:,t), KFFit.FilteredCov(:,:,t), ...
                KFFit.ForecastedMean(:,t+1), KFFit.ForecastedCov(:,:,t+1),...
                SmoothedMean(:,t+1), SmoothedCov(:,:,t+1));
    end
    Ctp1(:,:,1) = StateCov0*TranMX(:,:,1)'/KFFit.ForecastedCov(:,:,1);
    
    KalmanFit.loglik = KFFit.loglik;
    KalmanFit.ForecastedMean = KFFit.ForecastedMean;
    KalmanFit.ForecastedCov = KFFit.ForecastedCov;
    KalmanFit.FilteredMean = KFFit.FilteredMean;
    KalmanFit.FilteredCov = KFFit.FilteredCov;
    KalmanFit.SmoothedMean = SmoothedMean;
    KalmanFit.SmoothedCov = SmoothedCov;
    KalmanFit.Ctp1 = Ctp1;
    
%     %subject-fit
%     KalmanFit.YFilteredMean = KFFit.YFilteredMean;
%     KalmanFit.YFilteredCov = KFFit.YFilteredCov;
end