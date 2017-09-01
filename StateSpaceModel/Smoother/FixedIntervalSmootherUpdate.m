function [ xSmoothMean, xSmoothVar, ConvMX] = FixedIntervalSmootherUpdate(xSmoothMean,...
    xSmoothVar, xFilterMean, xFilterVar, xPredictMean, xPredictVar, TranMX)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    
    % Converting matrix
    ConvMX = xFilterVar * TranMX' / xPredictVar;
    
    % Smooth mean
    diffMean = xSmoothMean - xPredictMean;
    xSmoothMean = xFilterMean + ConvMX * diffMean;
    
    % Smooth variance
    diffVar = xSmoothVar - xPredictVar;
    xSmoothVar = xFilterVar + ConvMX * diffVar * ConvMX';
    
end

