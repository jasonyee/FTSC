% Under construction...
function [logLik, KalmanFull] = DSS2StepBuiltIn(ssm, Y)
%DSS2StepBuiltIn returns the dynamic state-space model fitting for Y
%   see (Guo, 2002)
%
%Input:
%   -ssm: state space model object
%   -Y: n-by-T matrix
%
%Output:
%   -logLik: log likelihood value for all Y
%   -KalmanFull: 2-by-1 structure array
    

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
    KalmanFull = repmat(Kalman, 2, 1);
    
    [n, T] = size(Y);
    % information: 1:(n-1) 
    Ym1 = Y(1:n-1,:);
    ssm1 = SubSSMBuiltIn(n-1, ssm);
    % filter to T
    [~, logL, fOut] = filter(ssm1, Ym1');
    % smooth back to 1
    [~, ~, sOut] = smooth(ssm1, Ym1');
    
    % get filtered, forecasted, smoothed states and covariances
    for t=T:-1:1
        Filtered(:,t) = fOut(t).FilteredStates;
        FilteredCov(:,:,t) = fOut(t).FilteredStatesCov;
        Predicted(:,t) = fOut(t).ForecastedStates;
        PredictedCov(:,:,t) = fOut(t).ForecastedStatesCov;
        Smoothed(:,t) = sOut(t).SmoothedStates;
        SmoothedCov(:,:,t) = sOut(t).SmoothedStatesCov;
    end
    % transition matrix, measurement matrix, error convariance matrix
    TranMX = repmat(ssm.A, 1,1,T);
    MeasMX = repmat(ssm.C, 1,1,T);
    ObseCov = repmat(ssm.D*ssm.D', 1,1,T);
    
    % ConvMinus
    for t=T-1:-1:1
        xFilterCov = FilteredCov(:,:,t);
        Tran = TranMX(:,:,t+1);
        xPredCov = PredictedCov(:,:,t+1);
        ConvMinus(:,:,t+1) =  xFilterCov* Tran' / xPredCov;
    end
    ConvMinus(:,:,1) = ssm.Cov0 * ssm.A' / fOut(1).ForecastedStatesCov;
    
    % smooth back to 0
    [Smoothed0, SmoothedCov0, ConvMinus(:,:,1)] = ...
        FixedIntervalSmootherUpdate(Smoothed(:,1),...
        SmoothedCov(:,:,1), ssm.Mean0, ssm.Cov0,...
        Predicted(:,1), PredictedCov(:,:,1), TranMX(:,:,1));
    
    KalmanFull(1).Filtered = Filtered;
    KalmanFull(1).FilteredCov = FilteredCov;
    KalmanFull(1).Predicted = Predicted;
    KalmanFull(1).PredictedCov = PredictedCov;
    KalmanFull(1).Smoothed = Smoothed;
    KalmanFull(1).SmoothedCov = SmoothedCov;
    KalmanFull(1).Smoothed0 = Smoothed0;
    KalmanFull(1).SmoothedCov0 = SmoothedCov0;
    KalmanFull(1).ConvMinus = ConvMinus;
    KalmanFull(1).logLik = logL;
    
    % new ssm
    [ TranMX, DistMean, DistCov, State0, StateCov0] = ...
    PriorConstruction(Smoothed, SmoothedCov, Smoothed0, SmoothedCov0, ConvMinus);
    
    % for last subject
    InfoUse = n;
    YInfoUse = Y(InfoUse, :);
    MeasMXInfoUse = MeasMX(InfoUse,:,:);
    ObseCovInfoUse = ObseCov(InfoUse,InfoUse,:);
    KalmanFull(2) = DSSUpdate(YInfoUse,...
                            TranMX,...
                            DistMean,...
                            DistCov,...
                            MeasMXInfoUse,...
                            ObseCovInfoUse,...
                            State0,...
                            StateCov0);
                         
    logLik = KalmanFull(1).logLik + KalmanFull(2).logLik;
    
end
