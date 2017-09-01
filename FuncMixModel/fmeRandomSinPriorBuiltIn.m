function Md = fmeRandomSinPriorBuiltIn(nSubj, t, logpara, diffusePrior)
%fmeRandomSinPriorBuiltIn returns a MATLAB's built-in state-space model object
% fixed effect: cubic spline, random effect: sin prior
% time-invariant

% dimension of the states
d = 2*(1+nSubj);

sigmae = exp(0.5 * logpara(1)); % sqrt of variance of measurement error
lambdaFSqrt = exp( 0.5 * logpara(2)); % sqrt of the fixed smoothing parameter
lambdaRSqrt = exp( 0.5 * logpara(3)); % sqrt of the random smoothing parameter
randomVars0 = exp(logpara(4:end)); % variances of initial random effects

% time-invariant
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


% State-disturbance-loading coefficients matrix 
% cubic spline fixed effect
FixedBlockCov = zeros(2);
FixedBlockCov(1,1) = deltaTj^3/3;
FixedBlockCov(2,2) = deltaTj;
FixedBlockCov(1,2) = deltaTj^2/2;
FixedBlockCov(2,1) = FixedBlockCov(1,2);
% Cholesky Factor
FixedBlockCovChol = chol(FixedBlockCov, 'lower');

% periodic random effect
RandomBlockCov = zeros(2);
RandomBlockCov(1,1) = deltaTj/(8*pi^2) - SinFourPiDeltaTj/(32*pi^3);
RandomBlockCov(2,2) = SinFourPiDeltaTj/(8*pi) + 0.5*deltaTj;
RandomBlockCov(1,2) = (1-CosFourPiDeltaTj)/(16*pi^2);
RandomBlockCov(2,1) = RandomBlockCov(1,2);
% Cholesky Factor
RandomBlockCovChol = chol(RandomBlockCov, 'lower');

FixedBlockCovChol = lambdaFSqrt * FixedBlockCovChol;
RandomBlockCovChol = lambdaRSqrt * RandomBlockCovChol;
RandomBlockCovCholnSubj = repmat({RandomBlockCovChol}, 1, nSubj);
DistCoefMX = blkdiag(FixedBlockCovChol, RandomBlockCovCholnSubj{:});

% Measurement-sensitivity coefficient matrix
Star = [1,0];
RandomStarnSubj = repmat({Star}, 1, nSubj);
MeasMX = [repmat(Star, nSubj, 1), blkdiag(RandomStarnSubj{:})];

% Observation-innovation coefficient matrix
ObseCoefMX = sigmae*eye(nSubj);

% Initial state mean
StateMean0 = zeros(d,1);

% Initial state covariance matrix
RandomCov0 = repmat({diag(randomVars0)}, 1, nSubj+1);
StateCov0 = blkdiag(RandomCov0{:});
StateCov0(1,1) = diffusePrior;
StateCov0(2,2) = diffusePrior;

% built-in ssm object
Md = ssm(TranMX, DistCoefMX, MeasMX, ObseCoefMX,...
            'Mean0', StateMean0, 'Cov0', StateCov0);
end

