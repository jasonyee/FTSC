function [xFilterMean, xFilterVar, xPredictMean, xPredictVar, logL] = ...
    KalmanFilterUpdate( xFilterMean, xFilterVar, yt, At, mut, Bt, Ct, Dt)


    % Predict the states
    xPredictMean = At * xFilterMean + mut;
    xPredictVar = At * xFilterVar * At' + Bt;
    
    if ~isnan(yt)
        % Predict the coming information
        yPredictMean = Ct * xPredictMean;
        yPredictError = yt - yPredictMean;
        xyPredictCov = xPredictVar * Ct';
        yPredictVar = Ct * xyPredictCov + Dt;


        % Use information to filter states
        KalmanGain = xyPredictCov / yPredictVar;
        xFilterMean = xPredictMean + KalmanGain * yPredictError;
        xFilterVar = xPredictVar - KalmanGain * xyPredictCov';

        % Numerical problems can cause asymmetry and non p.s.d of covariance matrix
        % It is necessary to repair.
        xFilterVar = RepairCov(xFilterVar);

        % Compute the likelihood function
        constant = length(yt) * log(2*pi);
        detTerm = log(det(yPredictVar));
        expTerm = yPredictError' / yPredictVar * yPredictError;
        logL = -0.5 * (constant + detTerm + expTerm);

    else
        xFilterMean = xPredictMean;
        xFilterVar = xPredictVar;
        logL = 0.;
    end

end

