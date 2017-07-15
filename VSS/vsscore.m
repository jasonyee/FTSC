%% vsscore
%  vsscore returns the optimization value or
%  the smoothed estimates of a state-space model.


function output_args = vsscore(dataset, StatesTran, StatesDist, MeasSens, ObseInno, Mean0, Cov0, Opti)
%(p is for subjects, m is for states, n is for observations)
%  -dataset is a p-by-n array:
%       dataset(:,t) = y_t
%  -StatesTran is a m-by-m-by-n array:
%       StatesTran(:,:,t) = T_{t-1}
%  -StatesDist is a m-by-m-by-n array:
%       StatesTran(:,:,t) = Q_{t-1}
%  -MeasSens is a p-by-m-by-n array:
%       MeasSens(:,:,t) = Z_t
%  -ObseInno is a p-by-p-by-n array:
%       ObseInno(:,:,t) = H_t
%  -Mean0 is a m-by-1 array for the initial state
%  -Cov0 is a m-by-m array for the covariance matrix of the initial state
%  -Opti is true when output_arg is the optimization value
%        is false when output_arg is a structure

%%  Initialization
    [p,m,n] = size(MeasSens);
    
    ForecastedStatesMean = zeros(m,n);  % (:,t) = a_t
    ForecastedStatesCov = zeros(m,m,n); % (:,t) = P_t
    SmoothedStatesMean = zeros(m,n);
    SmoothedStatesCov = zeros(m,m,n);
    ForecastedError = zeros(p,n);       % (:,t) = v_t: p-by-1
    F = zeros(p,p,n);                   % (:, :,t) = F_t: p-by-p
    KalmanGains = zeros(m,p,n);         % (:,:,t) = K_t: m-by-p
    L = zeros(m,m,n);                   % (:,:,t) = L_t: m-by-m
    
    loglik = 0.0;
    
%%  Kalman filtering
    ForecastedStatesMean(:,1) = StatesTran(:,:,1)*Mean0;
    ForecastedStatesCov(:,:,1) = StatesTran(:,:,1)*Cov0*StatesTran(:,:,1)'+ StatesDist(:,:,1);
    for t=1:n-1
        ForecastedError(:,t) = dataset(:,t) - MeasSens(:,:,t)*ForecastedStatesMean(:,t);
        foo = ForecastedStatesCov(:,:,t)*MeasSens(:,:,t)';
        F(:,:,t) = MeasSens(:,:,t)*foo + ObseInno(:,:,t);
        KalmanGains(:,:,t) = StatesTran(:,:,t+1)*foo/F(:,:,t);
        L(:,:,t) = StatesTran(:,:,t+1) - KalmanGains(:,:,t)*MeasSens(:,:,t);
        ForecastedStatesMean(:,t+1) = StatesTran(:,:,t+1)*ForecastedStatesMean(:,t)+ KalmanGains(:,:,t)*ForecastedError(:,t);
        ForecastedStatesCov(:,:,t+1) = StatesTran(:,:,t+1)*ForecastedStatesCov(:,:,t)*L(:,:,t)' + StatesDist(:,:,t+1);
    end
    ForecastedError(:,n) = dataset(:,n)- MeasSens(:,:,n)*ForecastedStatesMean(:,n);
    foo = ForecastedStatesCov(:,:,n)*MeasSens(:,:,n)';
    F(:,:,n) = MeasSens(:,:,n)*foo + ObseInno(:,:,n);

%%  Likelihood
    for t=1:n
        loglik = loglik + log(det(F(:,:,t))) + ForecastedError(:,t)'/F(:,:,t)*ForecastedError(:,t);
    end
    
%%  Optimization option
    if Opti
        output_args = loglik;
        return
    end
    
%%  State smoothing
    foo = MeasSens(:,:,n)'/F(:,:,n);
    rtm1 = foo*ForecastedError(:,n);    % <- r_{t-1}
    Ntm1 = foo*MeasSens(:,:,n);         % <- N_{t-1}
    for t=n:-1:2
        SmoothedStatesMean(:,t) = ForecastedStatesMean(:,t) + ForecastedStatesCov(:,:,t)*rtm1;
        SmoothedStatesCov(:,:,t) = ForecastedStatesCov(:,:,t) - ForecastedStatesCov(:,:,t)*Ntm1*ForecastedStatesCov(:,:,t);
        foo = MeasSens(:,:,t-1)'/F(:,:,t-1);
        rtm1 = foo*ForecastedError(:,t-1) + L(:,:,t-1)'*rtm1;
        Ntm1 = foo*MeasSens(:,:,t-1) + L(:,:,t-1)'*Ntm1*L(:,:,t-1);
    end
    SmoothedStatesMean(:,1) = ForecastedStatesMean(:,1) + ForecastedStatesCov(:,:,1)*rtm1;
    SmoothedStatesCov(:,:,1) = ForecastedStatesCov(:,:,1) - ForecastedStatesCov(:,:,1)*Ntm1*ForecastedStatesCov(:,:,1);
    
    output_args.SmoothedStatesMean = SmoothedStatesMean;
    output_args.SmoothedStatesCov = SmoothedStatesCov;
    output_args.loglik = loglik;

end

