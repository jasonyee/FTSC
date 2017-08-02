function [logLik, KalmanFull] = DSSFull(SSM, Y)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    
    % set-up
    [nstep, ~] = size(Y);
    TranMX = SSM.TranMX;
    DistMean = SSM.DistMean;
    DistCov = SSM.DistCov;
    MeasMX = SSM.MeasMX;
    ObseCov = SSM.ObseCov;
    State0 = SSM.StateMean0;
    StateCov0 = SSM.StateCov0;
    logLik = 0.0;
    
    % preallocation
    Kalman = struct('Filtered', {}, ...
                    'FilteredCov', {}, ...
                    'Predicted', {}, ...
                    'PredictedCov', {}, ...
                    'logLik', {}, ...
                    'Smoothed', {}, ...
                    'SmoothedCov', {}, ...
                    'Smoothed0', {}, ...
                    'SmoothedCov0', {}, ...
                    'ConvMinus', {});
    KalmanFull = repmat(Kalman, nstep, 1);
   
    for step=1:nstep
        InfoUse = step;
        YInfoUse = Y(InfoUse, :);
        MeasMXInfoUse = MeasMX(InfoUse,:,:);
        ObseCovInfoUse = ObseCov(InfoUse,InfoUse,:);
        [KalmanFull(step),...
         TranMX,...
         DistMean,...
         DistCov,...
         State0,...
         StateCov0] = DSSUpdate(YInfoUse,...
                                TranMX,...
                                DistMean,...
                                DistCov,...
                                MeasMXInfoUse,...
                                ObseCovInfoUse,...
                                State0,...
                                StateCov0);
                            
        logLik = logLik + KalmanFull(step).logLik;
    end
    
end

