%% fme2ss
%  converts a functional mixed effect model into a state-space model.

function SSM = fme2ss(nSubj, fixedArray, randomArray, t, logpara, diffusePrior)
%For functional mixed effect model, we let:
%   (nSubj for subjects, m for observations
%    p for fixed effects, q for random effects)
%   -fixedArray is 1-by-p.
%   -randomArray is 1-by-q.
%   -t is the observation time points, 1-by-m.
%   -para stores the parameters for optimization.
%       -e is the ***variance*** of the iid white noise.
%       -lambdaF, lambdaR are the smoothing parameters for
%           fixed effects and random effects.
%       -randomDiag contians the common prior variance parameters for 
%           random effects over all subject i
%           , 2q-by-1.
%   -diffuse is the diffuse prior variance parameter for fixed effect 
%       parameters.
%   -opti: true when KF is used in the minimization process.
%   for the detailed mathematics of this algorithms, please refer to:
%       http://www.jstor.org/stable/3068297?seq=1#page_scan_tab_contents

    % Optimization parameters
    %  e = sigma^2_e
    %  lambdaF = lambda_b
    %  lambdaR = lambda_a
    %  prior distribution
    %  randomDiag = (sigma_{11}^2,sigma_{12}^2,...,
    %               sigma_{q1}^2,sigma_{q2}^2)
    
    
    m = length(t);                              % observations
    
    p = length(fixedArray);                           % # of fixed effects;
    q = length(randomArray);                          % # of random effects
    
    fixedDesign = repmat(fixedArray,nSubj, 1);    % n-by-p
    randomDesign = repmat(randomArray,nSubj, 1);   % n-by-q
  
    d = 2*(p+nSubj*q);                              % dimension of states
    
    e = exp(logpara(1));
    lambdaF = exp(logpara(2));
    lambdaR = exp(logpara(3));
    randomDiag = exp(logpara(4:end));
    
    % Initialize 
    
    H0 = repmat(zeros(d, d), [1, 1, m]);        % H0(:,:,j) <- Hj
    sigma0 = H0;                                % sigma0(:,:,j) <- Wj

    
    %  cache variable
    XStar = zeros(nSubj,2*p);                       % XStar(i,:) <- X*_{ij}
    ZStar = zeros(1,2*q);                       % ZStar <- Z*_{ij}
    ZStarDiagCell = cell(1,nSubj);
    
    %  store the diagonal block     
    HjCell = cell(1,p+nSubj*q);
    WjCell = cell(1,p+nSubj*q);
    P00Cell = cell(1, nSubj+1);
    
    % Output
    %  Design matrix: F is n-by-d-by-m  
    % XStar setup
    for v=1:p
        XStar(:,2*v-1) = fixedDesign(:,v);
    end
    % ZStar setup
    for i=1:nSubj
        for u=1:q
            ZStar(2*u-1) = randomDesign(i,u);
        end
        ZStarDiagCell{i} = ZStar;
    end
    % F(:,:,j) <- Fj 
    F = repmat([XStar, blkdiag(ZStarDiagCell{:})], 1, 1, m);            %  Done

    
    %  tensor that stores all white noise covariance matrices
    sigma_e = repmat(e*eye(nSubj), [1,1,m]);                            %  Done            
    
    
    %  deltaT
    T0 = [0, t];
    deltaT = t - T0(1:m);
    
    %  state transition tensor: H0 
    %  initial covariance tensor for noise of states: sigma0
    for j=1:m
        %  2-by-2 basic block
        twoPiDeltaTj = 2*pi*deltaT(j);
        fourPiDeltaTj = 2*twoPiDeltaTj;
        SinTwoPiDeltaTj = sin(twoPiDeltaTj);
        CosTwoPiDeltaTj = cos(twoPiDeltaTj);
        SinFourPiDeltaTj = sin(fourPiDeltaTj);
        CosFourPiDeltaTj = cos(fourPiDeltaTj);
        HjBasic = [CosTwoPiDeltaTj, SinTwoPiDeltaTj/(2*pi);...
                    -2*pi*SinTwoPiDeltaTj, CosTwoPiDeltaTj];
        WjBasic = [deltaT(j)/(8*pi^2) - SinFourPiDeltaTj/(32*pi^3),...
                    (1-CosFourPiDeltaTj)/(16*pi^2);...
                    (1-CosFourPiDeltaTj)/(16*pi^2),...
                    SinFourPiDeltaTj/(8*pi) + 0.5*deltaT(j)];
        WjFixedBasic = WjBasic/lambdaF;
        WjRandomBasic = WjBasic/lambdaR;
        
        %  constructing block diagonal matrices
        for v=1:(p+nSubj*q)
            HjCell{v} = HjBasic;
            if (v <= p)
                WjCell{v} = WjFixedBasic;
            else 
                WjCell{v} = WjRandomBasic;
            end
        end
        %  Hj and Wj
        H0(:,:,j) = blkdiag(HjCell{:});                             %  Done
        sigma0(:,:,j) = blkdiag(WjCell{:});                         %  Done
    end
    
    
    %  prior mean for x(0): x00
    x00 = zeros(d,1);                                               %  Done
    
    %  prior variance matrix for x(0): P00
    P00Cell{1} = diffusePrior*eye(2*p);
    for v=2:(nSubj+1)
        P00Cell{v} = diag(randomDiag);
    end
    P00 = blkdiag(P00Cell{:});                                      %  Done
    
    SSM.TranMX = H0;
    SSM.DistMean = zeros(d,m);
    SSM.DistCov = sigma0;
    SSM.MeasMX = F;
    SSM.ObseCov = sigma_e;
    SSM.StateMean0 = x00;
    SSM.StateCov0 = P00;
    
end

