function [Filtered, FilteredCov, Predicted, PredictedCov, logLik] = ...
    KalmanFilter(Y, TranMX, DistMean, DistCov, MeasMX, ObseCov, State0, StateCov0)
%KalmanFilter output the filtered and predicted estimates of latent states
%   -Y: n-by-T
%   -TranMX: d-by-d-by-T
%   -DistMean: d-by-T
%   -DistCov: d-by-d-by-T
%   -MeasMX: n-by-by-d-byT
%   -ObseCov: n-by-n-by-T
%   -State0: d-by-1
%   -StateCov0: d-by-d
%   -logLik is the log likelihood for Y(:,1:T)
    
    [~, d, T] = size(MeasMX);
    Filtered = zeros(d, T);
    FilteredCov = zeros(d, d, T);
    Predicted = zeros(d, T);
    PredictedCov = zeros(d, d, T);
    
    xFilterMean = State0;
    xFilterVar = StateCov0;
    
    logL = zeros(T,1);
    
    for t=1:T
        
        [xFilterMean, xFilterVar,...
         Predicted(:,t), PredictedCov(:,:,t),...
         logL(t)] = ...
                KalmanFilterUpdate( xFilterMean, xFilterVar, Y(:,t),...
                TranMX(:,:,t), DistMean(:,t), DistCov(:,:,t),...
                MeasMX(:,:,t), ObseCov(:,:,t));

        Filtered(:,t) = xFilterMean;
        FilteredCov(:,:,t) = xFilterVar;
        
    end
    
    logLik = sum(logL);
    
end

