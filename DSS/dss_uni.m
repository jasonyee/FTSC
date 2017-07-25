%% dss_uni
%  dss_uni trains a dynamic state-space model
%  for the given state-space model and data

function [KalmanFitCell, loglik, prior]= ...
    dss_uni(TranMX, DistMean, DistCov, MeasMX, ObseCov, data, StateMean0, StateCov0)
%Input: t=1:T
%   -TranMX(:,:,t): the state transtion matix from t-1 to t.
%   -DistMean(:,t): the state disturbing mean at t.
%   -DistCov(:,:,t): the state disturbing covariance matrix from t-1 to t.
%   -MeasMX(:,:,t): the measurement matrix at t.
%   -ObseCov(:,:,t): the observation innovation covariance matrix at t.
%   -data(:,t): the dependent data at t.
%   -StateMean0(:): the initial states, t=0.
%   -StateCov0(:,:): the initial states covariance matrix, t=0.
%Output: 
%   KalmanFitCell{i} is a structures, i=1:n
%       -loglik: log-likelihood for subject (i) given 1:i-1.
%       -ForecastedMean: E(x^(i-1)_t|1:t-1)
%       -ForecastedCov: Cov(x^(i-1)_t|1:t-1)
%       -FilteredMean: E(x^(i-1)_t|1:t)
%       -FilteredCov: Cov(x^(i-1)_t|1:t)
%       -SmoothedMean: E(x^(i-1)_t|1:T)
%       -SmoothedCov: Cov(x^(i-1)_t|1:T)
%   loglik is the log-likelihood value for all the data.
%   prior is a structure storing the prior info for the new subject.
%       -OneSubTranMX: (:,:,t) is the state transition matrix
%       -OneSubDistMean: (:,t) is the state disturbance mean
%       -OneSubDistCov: (:,:,t) is the state disturbance covariance matrix
%       -OneSubState0: initial state mean
%       -OneSubStateCov0: initial state covariance matrix


    [n, ~, T] = size(MeasMX);
    KalmanFitCell = cell(n,1);
    loglik = 0.0;
    
    OneSubTranMX = TranMX;
    OneSubDistMean = DistMean;
    OneSubDistCov = DistCov;
    OneSubState0 = StateMean0;
    OneSubStateCov0 = StateCov0;
    
    for i=1:n
        KalmanFit = KS(OneSubTranMX, OneSubDistMean, OneSubDistCov, ...
                        MeasMX(i,:,:), ObseCov(i,i,:), data(i,:), ...
                        OneSubState0, OneSubStateCov0);
        %updating the priors
        OneSubState0 = OneSubState0 + ...
            KalmanFit.Ctp1(:,:,1)*(KalmanFit.SmoothedMean(:,1) ...
            - KalmanFit.ForecastedMean(:,1));
        OneSubStateCov0 = OneSubStateCov0 + ...
            KalmanFit.Ctp1(:,:,1)*(KalmanFit.SmoothedCov(:,:,1) ...
            - KalmanFit.ForecastedCov(:,:,1))*KalmanFit.Ctp1(:,:,1)';
        for t=1:T
            if t==1
                OneSubTranMX(:,:,t) = KalmanFit.SmoothedCov(:,:,t) ...
                    *KalmanFit.Ctp1(:,:,t)'/OneSubStateCov0;
                OneSubDistMean(:,t) = KalmanFit.SmoothedMean(:,t) ...
                    - OneSubTranMX(:,:,t)*OneSubState0;
                OneSubDistCov(:,:,t) = KalmanFit.SmoothedCov(:,:,t) ...
                    - OneSubTranMX(:,:,t)*OneSubStateCov0...
                    *OneSubTranMX(:,:,t)';
            else
                OneSubTranMX(:,:,t) = KalmanFit.SmoothedCov(:,:,t) ...
                    *KalmanFit.Ctp1(:,:,t)'/KalmanFit.SmoothedCov(:,:,t-1);
                OneSubDistMean(:,t) = KalmanFit.SmoothedMean(:,t) ...
                    - OneSubTranMX(:,:,t)*KalmanFit.SmoothedMean(:,t-1);
                OneSubDistCov(:,:,t) = KalmanFit.SmoothedCov(:,:,t) ...
                    - OneSubTranMX(:,:,t)*KalmanFit.SmoothedCov(:,:,t-1)...
                    *OneSubTranMX(:,:,t)';
            end
        end
        KalmanFitCell{i} = KalmanFit;
        
        loglik = loglik + KalmanFit.loglik;
    end
    prior.OneSubTranMX = OneSubTranMX;
    prior.OneSubDistMean = OneSubDistMean;
    prior.OneSubDistCov = OneSubDistCov;
    prior.OneSubState0 = OneSubState0;
    prior.OneSubStateCov0 = OneSubStateCov0;
end

