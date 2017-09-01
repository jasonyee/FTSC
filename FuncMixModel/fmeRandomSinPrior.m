function SSM = fmeRandomSinPrior(nSubj, t, logpara, diffusePrior)
%fmeRandomSinPrior returns a state-space model structure
% fixed effect: cubic spline, random effect: sin prior
% time-invariant

% preallocation for SSM
SSM = struct('TranMX', [], ...
             'DistMean', [], ...
             'DistCov', [], ...
             'MeasMX', [], ...
             'ObseCov', [], ...
             'StateMean0', [], ...
             'StateCov0', []);

% dimension of the states
d = 2*(1+nSubj);

sigma2e = exp(logpara(1));  % variance of measurement error
lambdaF = exp(logpara(2));   % the fixed smoothing parameter
lambdaR = exp(logpara(3));   % the random smoothing parameter
randomVars0 = exp(logpara(4:end));   % variances of initial random effects

% time-invariant
T = length(t);
deltaTj = t(2) - t(1);

% prepared for calculation
twoPiDeltaTj = 2*pi*deltaTj;
fourPiDeltaTj = 2*twoPiDeltaTj;
SinTwoPiDeltaTj = sin(twoPiDeltaTj);
CosTwoPiDeltaTj = cos(twoPiDeltaTj);
SinFourPiDeltaTj = sin(fourPiDeltaTj);
CosFourPiDeltaTj = cos(fourPiDeltaTj);


% State-transition coefficients matrix
% cubic spline fixed effect
FixedBlockT = [1, deltaTj;...
                0, 1];
            
% periodic random effect
RandomBlockT = [CosTwoPiDeltaTj, SinTwoPiDeltaTj/(2*pi);...
                -2*pi*SinTwoPiDeltaTj, CosTwoPiDeltaTj];
RandomBlockTnSubj = repmat({RandomBlockT}, 1, nSubj);
TranMX = blkdiag(FixedBlockT, RandomBlockTnSubj{:});


% State-disturbance-loading variance-covariance matrix 
% cubic spline fixed effect
FixedBlockCov = zeros(2);
FixedBlockCov(1,1) = deltaTj^3/3;
FixedBlockCov(2,2) = deltaTj;
FixedBlockCov(1,2) = deltaTj^2/2;
FixedBlockCov(2,1) = FixedBlockCov(1,2);

% periodic random effect
RandomBlockCov = zeros(2);
RandomBlockCov(1,1) = deltaTj/(8*pi^2) - SinFourPiDeltaTj/(32*pi^3);
RandomBlockCov(2,2) = SinFourPiDeltaTj/(8*pi) + 0.5*deltaTj;
RandomBlockCov(1,2) = (1-CosFourPiDeltaTj)/(16*pi^2);
RandomBlockCov(2,1) = RandomBlockCov(1,2);

% fixed effect block
FixedBlockC = lambdaF * FixedBlockCov;
% random effect block
RandomBlockC = lambdaR * RandomBlockCov;
RandomBlockCnSubj = repmat({RandomBlockC}, 1, nSubj);
DistCov = blkdiag(FixedBlockC, RandomBlockCnSubj{:});

% Measurement-sensitivity coefficient matrix
Star = [1,0];
RandomStarnSubj = repmat({Star}, 1, nSubj);
MeasMX = [repmat(Star, nSubj, 1), blkdiag(RandomStarnSubj{:})];

% Observation-innovation covaraince matrix
ObseCov = sigma2e*eye(nSubj);


% Initial state covariance matrix
RandomCov0 = repmat({diag(randomVars0)}, 1, nSubj+1);
StateCov0 = blkdiag(RandomCov0{:});
StateCov0(1,1) = diffusePrior;
StateCov0(2,2) = diffusePrior;

% SSM structure
SSM.TranMX = repmat(TranMX, 1, 1, T);
SSM.DistMean = zeros(d, T);
SSM.DistCov = repmat(DistCov, 1, 1, T);
SSM.MeasMX = repmat(MeasMX, 1, 1, T);
SSM.ObseCov = repmat(ObseCov, 1, 1, T);
SSM.StateMean0 = zeros(d,1);
SSM.StateCov0 = StateCov0;

end

