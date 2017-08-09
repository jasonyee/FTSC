%% fme2ss
%  converts a functional mixed effect model into a state-space model.

function SSM = fme2ss(nSubj, fixedArray, randomArray, t, logpara, diffusePrior)
%For functional mixed effect model, we let:
%   (nSubj for subjects, m for observations
%    p for fixed effects, q for random effects)
%   -fixedArray is 1-by-p.
%   -randomArray is 1-by-q.
%   -t is the observation time points, 1-by-m.
%   -logpara stores the logrithmic parameters for optimization.
%       -(1): log(sigma^2_e)
%       -(2): log(lambdaF)
%       -(3): log(lambdaR)
%       -(4:end): log(diagonal elements for the prior covariance of random effect)
%   for the detailed mathematics of this algorithms, please refer to:
%       http://www.jstor.org/stable/3068297?seq=1#page_scan_tab_contents
    
    
    m = length(t);                              % observations
    
    p = length(fixedArray);                           % # of fixed effects;
    q = length(randomArray);                          % # of random effects
    
    d = 2*(p+nSubj*q);                              % dimension of states
    
    sigma2e = exp(logpara(1));
    lambdaF = exp(logpara(2));
    lambdaR = exp(logpara(3));
    randomDiag = exp(logpara(4:end));
    
    %  deltaT
    T0 = [0, t];
    deltaT = t - T0(1:m);

    
    %  Transition matrix and disturbance covariance matrix
    SSM.TranMX = zeros(d, d, m);
    for j=1:m
        %  2-by-2 basic block
        twoPiDeltaTj = 2*pi*deltaT(j);
        fourPiDeltaTj = 2*twoPiDeltaTj;
        SinTwoPiDeltaTj = sin(twoPiDeltaTj);
        CosTwoPiDeltaTj = cos(twoPiDeltaTj);
        SinFourPiDeltaTj = sin(fourPiDeltaTj);
        CosFourPiDeltaTj = cos(fourPiDeltaTj);
%         % periodic fixed effect
%         HjFixedBasic = [CosTwoPiDeltaTj, SinTwoPiDeltaTj/(2*pi);...
%                     -2*pi*SinTwoPiDeltaTj, CosTwoPiDeltaTj];
        % linear spline fixed effect
        HjFixedBasic = [1, deltaT(j);
                        0, 1];        
        HjRandomBasic = [CosTwoPiDeltaTj, SinTwoPiDeltaTj/(2*pi);...
                    -2*pi*SinTwoPiDeltaTj, CosTwoPiDeltaTj];
%         % periodic fixed effect
%         WjFixedBasic = [deltaT(j)/(8*pi^2) - SinFourPiDeltaTj/(32*pi^3),...
%                     (1-CosFourPiDeltaTj)/(16*pi^2);...
%                     (1-CosFourPiDeltaTj)/(16*pi^2),...
%                     SinFourPiDeltaTj/(8*pi) + 0.5*deltaT(j)]/lambdaF;
        % linear spline fixed effect
        WjFixedBasic = [deltaT(j)^3/3, deltaT(j)^2/2;...
                        deltaT(j)^2/2, deltaT(j)];
        WjRandomBasic = [deltaT(j)/(8*pi^2) - SinFourPiDeltaTj/(32*pi^3),...
                    (1-CosFourPiDeltaTj)/(16*pi^2);...
                    (1-CosFourPiDeltaTj)/(16*pi^2),...
                    SinFourPiDeltaTj/(8*pi) + 0.5*deltaT(j)]/lambdaR;
        
        % Transition matrix
        HjFixedCell = repmat({HjFixedBasic}, 1, p);
        HjRandomCell = repmat({HjRandomBasic}, 1, nSubj*q);
        SSM.TranMX(:,:,j) = blkdiag(HjFixedCell{:}, HjRandomCell{:});

        
        % Disturbance covariance matrix
        WjFixedCell = repmat({WjFixedBasic}, 1, p);
        WjRandomCell = repmat({WjRandomBasic}, 1, nSubj*q);
        SSM.DistCov(:,:,j) = blkdiag(WjFixedCell{:}, WjRandomCell{:});

    end
    
    %  Disturbance mean
    SSM.DistMean = zeros(d, m);
    
    
    %  Measurement matrix
    fixedArrayStar = zeros(1, 2*p);
    for v=1:p
        fixedArrayStar(2*v-1) = fixedArray(v);
    end
    randomArrayStar = zeros(1, 2*q);
    for v=1:q
        randomArrayStar(2*v-1) = randomArray(v);
    end
    randomArrayStarCell = repmat({randomArrayStar}, 1, nSubj);
    Fj = [repmat(fixedArrayStar, nSubj, 1),...
        blkdiag(randomArrayStarCell{:})];
    SSM.MeasMX = repmat(Fj, 1, 1, m);

    %  Observation error covariance matrix
    SSM.ObseCov = repmat(sigma2e*eye(nSubj),1,1,m);
    
    %  State0 mean
    SSM.StateMean0 = zeros(d,1);
    
    %  State0 covariance matrix
    randomCovCell = repmat({diag(randomDiag)}, 1, nSubj);
    SSM.StateCov0 = blkdiag(diffusePrior*eye(2*p), randomCovCell{:});
    
end

