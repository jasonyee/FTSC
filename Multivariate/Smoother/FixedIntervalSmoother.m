function [Smoothed, SmoothedCov, Smoothed0, SmoothedCov0, ConvMinus ] = ...
    FixedIntervalSmoother(Filtered, FilteredCov, Predicted, PredictedCov, TranMX, State0, StateCov0)
%FixedIntervalSmoother computes the smooth estimates of states
%   see Durbin and Koopman (2012)
    
    % get dimensions
    [~, d, T] = size(TranMX);
    
    % initialize the smoothed value and preallocation
    Smoothed = Filtered;
    SmoothedCov = FilteredCov;
    ConvMinus = zeros(d, d, T);
    
    xSmoothMean = Smoothed(:, T);
    xSmoothVar = SmoothedCov(:, :, T);
    
    for t=T-1:-1:1
        
        % Backward smoothing recusion
        [xSmoothMean, xSmoothVar, ConvMinus(:,:,t+1)] = ...
            FixedIntervalSmootherUpdate(xSmoothMean,...
            xSmoothVar, Filtered(:,t), FilteredCov(:,:,t),...
            Predicted(:,t+1), PredictedCov(:,:,t+1), TranMX(:,:,t+1));
        
        % store smoothed states
        Smoothed(:,t) = xSmoothMean;
        SmoothedCov(:,:,t) = xSmoothVar;
        
    end
    
    % smooth the initial state
    [Smoothed0, SmoothedCov0, ConvMinus(:,:,1)] = ...
        FixedIntervalSmootherUpdate(xSmoothMean,...
        xSmoothVar, State0, StateCov0,...
        Predicted(:,1), PredictedCov(:,:,1), TranMX(:,:,1));

end

