function [ xSmoothMean, xSmoothVar, ConvMX] = FixedIntervalSmootherUpdate(xSmoothMean,...
    xSmoothVar, xFilterMean, xFilterVar, xPredictMean, xPredictVar, TranMX)
%fixed interval smoothing algorithm for one-step
%   see Durbin and Koopman (2012)
    
    % Converting matrix
    ConvMX = xFilterVar * TranMX' / xPredictVar;
    
    % Smooth mean
    diffMean = xSmoothMean - xPredictMean;
    xSmoothMean = xFilterMean + ConvMX * diffMean;
    
    % Smooth variance
    diffVar = xSmoothVar - xPredictVar;
    xSmoothVar = xFilterVar + ConvMX * diffVar * ConvMX';
    
end

