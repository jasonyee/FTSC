function [logL,xFilterMean,xFilterVar,xForecastMean,xForecastVar]...
    = FilterUpdate(xFilterMean,xFilterVar,yt,At, mut, Bt, Ct, Dt)

    logL = 0;
    tol = 0;
    % Forecast the states
    xForecastMean = At * xFilterMean + mut;
    xForecastVar = At * xFilterVar * At' + Bt;

    infoUse = ~isnan(yt);

    % Forecast the coming information
    yForecastMean = Ct * xForecastMean;
    yForecastError = yt - yForecastMean;
    xyForecastCov = xForecastVar * Ct';
    yForecastVar = Ct * xyForecastCov + Dt;

    % Occasionally, some information are not informative
    % Note that only non-NaN information will be tested, hence double mask.
    infoUse(infoUse) = statespace.isinfo(yForecastVar(infoUse,infoUse),tol);

    % Compute the chol factor of forecast variance
    % If it fails, it means there are remaining redundant information
    % and thus need strict removal of redundancy
    % In rare cases that yForecastVarCut still cannot be positive definite
    % discard all information in that period.
    yForecastVarCut = yForecastVar(infoUse,infoUse);
    [Pchol,testPSD] = chol(yForecastVarCut,'lower');
    if testPSD > 0
        infoUse(infoUse) = statespace.isinfo(yForecastVar(infoUse,infoUse),tol,true);    
        yForecastVarCut = yForecastVar(infoUse,infoUse);
        [Pchol,testPSD] = chol(yForecastVarCut,'lower');
        if testPSD > 0
            infoUse(:) = false;
            yForecastVarCut = yForecastVar(infoUse,infoUse);
        end
    end    

    % If there is no informative information, we can leave now
    if ~any(infoUse)
        xFilterMean = xForecastMean;
        xFilterVar = xForecastVar;   
        return
    end

    % Use information to filter states
    xyForecastCovCut = xyForecastCov(:,infoUse);
    yForecastErrorCut = yForecastError(infoUse,1);
    KalmanGainRaw = xyForecastCovCut / yForecastVarCut;
    xFilterMean = xForecastMean + KalmanGainRaw * yForecastErrorCut;
    xFilterVar = xForecastVar - KalmanGainRaw * xyForecastCovCut';

    % Numerical problems can cause asymmetry and non p.s.d of covariance matrix
    % It is necessary to repair.
    xFilterVar = statespace.repairCov(xFilterVar);

    % Compute the likelihood function
    constant = -0.5*sum(infoUse)*log(2*pi);
    detTerm = -sum(log(diag(Pchol)));
    yTran = Pchol \ yForecastErrorCut;
    expTerm = -0.5 * sum(yTran.*yTran);
    logL = constant + detTerm + expTerm;
    
end

