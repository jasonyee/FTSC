function [Filtered, FilteredCov, Predicted, PredictedCov, logLik] = ...
    KalmanFilter(Y, TranMX, DistMean, DistCov, MeasMX, ObseCov, State0, StateCov0)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
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

