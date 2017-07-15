%% vss_uni2
%  vectorized state space model with mean 0
%  This is for the noise in state equation with mean 0 and
%  using state smoothing

function output_args = vss_uni2(Y, Z, sigma2e, T, Q, a00, P00, opti)
%(p for subjects, n for observations, m for dimension of states)
%   -Y is the data: Y(:,:) is a p-by-n matrix, Y(i,t) = y_{t,i}.
%   -Z is a 3-dimensional array to represent the design:
%       Z(:,:,:) is p-by-m-by-n.
%       note that Z(i,:,t) = Z_{t,i} is a row vector that stores 
%       the design for alpha_{t,i}.
%   -sigma2_e is p-by-p-by-n array, sigma2_e(:,:,t) = H_t stores the variance 
%       of the ith variate at time t.
%   -T is the state transition tensor, m-by-m-by-n, T(:,:,t) = T_t.
%       alpha_t = T_t alpha_{t-1} + eta_t.
%   -Q is the covariance tensor for noise in signal evolving
%       m-by-m-by-n, sigma20(:,:,t) = Q_t.
%       Note that values have been squared.
%   -a00 is the initial unconditional mean for alpha(0), m-by-1
%   -P00 is the initial unconditional variance for alpha(0), m-by-m
%   -opti is boolean: if True then the function returns the criterion value;
%       otherwise the signals and the variances are returned too
%   for the detailed mathematics of this algorithms, please refer to:
%       http://personal.vu.nl/s.j.koopman/old/publications/DKFastFiltering.pdf

    %% Initialization
    [p, n] = size(Y);
    loglik = 0.0;
    alphaSize = size(a00);
    m = alphaSize(1);
    
    %  updating variables
    adtm1 = a00;                    % <- a_{t-1|t-1}
    
    Pdtm1 = P00;                    % <- P_{t-1|t-1}
    
    rt = zeros(m,1);               % rt <- r_t
    Nt = zeros(m,m);               % Nt <- N_t
                                   % Initialized later:
                                   % attm1 <- a_{t|t-1}
                                   % Pttm1 <- P_{t|t-1}
    
    %  storage variables
    %  alpha_t|Y_{t-1}
    OneStepMean = zeros(m,n);       % (:,t) = a_t
    OneStepVar = zeros(m,m,n);      % (:,:,t) = P_t
    %  alpha_t|Y_t
    FilteredMean = zeros(m,n);      % (:,t) = a_{t|t}
    FilteredVar = zeros(m,m,n);     % (:,:,t) = P_{t|t}
    %  alpha_t|Y_n
    SmoothedMean = zeros(m,n);      % (:,t) = alphahat_t
    SmoothedVar = zeros(m,m,n);     % (:,:,t) = V_t
    %  One-step forward
    YMean = zeros(p,n);             % (:,t) = E[y_t|Y_{t-1}]
    YVar = zeros(p,n);              % (i,t) = Var[y_{t,i}|Y_{t-1}]
    
    %  For computing
    kal = zeros(m,p,n);             % (:,:,t) = K_{t}
    F = zeros(p,p,n);               % (:,:,t) = F_t
    v = zeros(p,n);                 % (:,t) = v_t
    
    
    %% Algorithm
    
    %  filtering
    for t=1:n
        adtm1 = T(:,:,t)*adtm1;
        Pdtm1 = T(:,:,t)*Pdtm1*T(:,:,t)' + Q(:,:,t);
        OneStepMean(:,t) = adtm1;
        OneStepVar(:,:,t) = Pdtm1;
        v(:,t) = Y(:,t) - Z(:,:,t)*adtm1;
        kal(:,:,t) = Pdtm1*Z(:,:,t)';
        F(:,:,t) = Z(:,:,t)*kal(:,:,t) + sigma2e(:,:,t);
        loglik = loglik + log(det(F(:,:,t))) + v(:,t)'/F(:,:,t)*v(:,t);
        G = kal(:,:,t)/F(:,:,t);
        adtm1 = adtm1 + G*v(:,t);
        Pdtm1 = Pdtm1 - G*kal(:,:,t)';
        FilteredMean(:,t) = adtm1;
        FilteredVar(:,:,t) = Pdtm1;
%         cond(Pdtm1)
    end
    
    %  smoothing
    for t=n:-1:1
        L = eye(m) - kal(:,:,t)/F(:,:,t)*Z(:,:,t);
        G = Z(:,:,t)'/F(:,:,t);
        rt = G*v(:,t) + L'*rt;
        Nt = G*Z(:,:,t) + L'*Nt*L;
        SmoothedMean(:,t) = OneStepMean(:,t)+OneStepVar(:,:,t)*rt;
        SmoothedVar(:,:,t) = OneStepVar(:,:,t)... 
                             - OneStepVar(:,:,t)*Nt*OneStepVar(:,:,t);
        rt = T(:,:,t)'*rt;
        Nt = T(:,:,t)'*Nt*T(:,:,t);
    end 
    
    %% Inference about Y
    for t=1:n
        YMean(:,t) = Z(:,:,t)*FilteredMean(:,t);
        YVar(:,t) = diag(Z(:,:,t)*FilteredVar(:,:,t)*Z(:,:,t)')...
                        + diag(sigma2e(:,:,t));
    end
    
    
    %% Output
    
    if (opti)
        % return the criterion value for optimization
        output_args = loglik;
    else
        % as well as smoothed and filtered signals and their variances
        output_args = {loglik,...
                       SmoothedMean, SmoothedVar,...          %1 to n
                       FilteredMean, FilteredVar,...
                       YMean, YVar};
    end
    
end

