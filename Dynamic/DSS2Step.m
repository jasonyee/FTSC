function [logLik, Kalman2Step] = DSS2Step(SSM, Y)
%DSS2STEP computes the dynamic state space model in 2-step updating process
% Description:
%
% In the first step, Y(1:end-1, :) is processed.
% in the second step, Y(end, :) is processed. see Guo (2003)
%
% Input Arguments:
%   
%   Information: Y
%   Initial state space model structure: SSM
%
% Output Arguments:
%
%   logLik - log-likelihood for Y(:,:)
%   KalmanFull - 2-by-1 Kalman structure array
    
    % set-up
    nstep = 2;
    [n, ~] = size(Y);
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
    Kalman2Step = repmat(Kalman, nstep, 1);
   
    for step=1:nstep
        % get the information at this step
        if step == 1
            InfoUse = 1:n-1;
        else
            InfoUse = n;
        end
        
        YInfoUse = Y(InfoUse, :);
        MeasMXInfoUse = MeasMX(InfoUse,:,:);
        ObseCovInfoUse = ObseCov(InfoUse,InfoUse,:);
        [Kalman2Step(step),...
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
                            
        logLik = logLik + Kalman2Step(step).logLik;
    end
    
end

