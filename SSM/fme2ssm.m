%% fme2ssm
%  fme2ssm creats a structure that specifies a state-space model object in
%  MATLAB@2016a from a mixed effect model.

%% Assumption
%  -The noise in functional mixed effect model is Gaussian white noise and
%  i.i.d over the time and subject.

function SSModelStruc = fme2ssm(fixedDesign, randomDesign, OBtime, logpara)
% For functional mixed effect model, we let:
%   (n for subjects, m for observations
%    p for fixed effects, q for random effects)
%   -dataset is the dependent data: 
%       dataset(:,:) is a n-by-m matrix. 
%   -fixedDesign is n-by-p-by-m.
%   -randomDesign is n-by-q-by-m.
%   -OBtime is the observation time points, 1-by-m.
%   -logpara stores the logs of all parameters for optimization.
%       -sigma_e is the ***standard deviation*** of the iid white noise.
%       -lambdaF, lambdaR are the smoothing parameters for
%           fixed effects and random effects.
%       -randomDiag contians the common prior variance parameters for 
%           random effects over all subject i
%           , 2q-by-1.
%   for the detailed mathematics of this algorithms, please refer to:
%       http://www.jstor.org/stable/3068297?seq=1#page_scan_tab_contents

    %% Optimization parameters
    %  e = sigma_e
    %  lambdaF = lambda_b
    %  lambdaR = lambda_a
    %  prior distribution
    %  randomDiag = (sigma_{11}^2,sigma_{12}^2,...,
    %               sigma_{q1}^2,sigma_{q2}^2)

    diffusePrior = 1e7;

    [n, p, m] = size(fixedDesign);              % subjects and observations
                                                % # of fixed effects
    randomSize = size(randomDesign);
    q = randomSize(2);                          % # of random effects

    d = 2*(p+n*q);                              % dimension of states

    sigma_e = exp(logpara(1));
    lambdaF = exp(logpara(2));
    lambdaR = exp(logpara(3));
    randomDiag = exp(logpara(4:end));

    %% Initialize 

    measSensMatrix = cell(1,m);         % measSensMatrix{j} <- Fj
    obseInnovMatrix = cell(1,m);        % obseInnovMatrix{j}obseInnovMatrix{j}' <- sigma^2_e I_n
    stateTranMatrix = cell(1,m);        % stateTranMatrix{j} <- Hj
    stateDistMatrix = cell(1,m);        % stateDistMatrix{j}stateDistMatrix{j}'<- Wj


    %  cache variable
    XStar = zeros(n,2*p);                       % XStar(i,:) <- X*_{ij}
    ZStar = zeros(1,2*q);                       % ZStar <- Z*_{ij}
    ZStarDiagCell = cell(1,n);

    %  store the diagonal block     
    HjCell = cell(1,p+n*q);
    WjCell = cell(1,p+n*q);
    Cov0Cell = cell(1, n+1);

    %% Output
    %  Design matrix: F is n-by-d-by-m    
    for j=1:m
        % XStar setup
        for v=1:p
            XStar(:,2*v-1) = fixedDesign(:,v,j);
        end
        % ZStar setup
        for i=1:n
            for u=1:q
                ZStar(2*u-1) = randomDesign(i,u,j);
            end
            ZStarDiagCell{i} = ZStar;
        end
        measSensMatrix{j} = [XStar, blkdiag(ZStarDiagCell{:})];     % Done
    end

    %  tensor that stores all white noise covariance matrices
                                 %  Done            
    for j = 1:m
        obseInnovMatrix{j} = sigma_e*eye(n);                        % Done
    end

    %  deltaT
    T0 = [0, OBtime];
    deltaT = OBtime - T0(1:m);

    %  state transition matrix: H0 
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
        for v=1:(p+n*q)
            HjCell{v} = HjBasic;
            if (v <= p)
                WjCell{v} = WjFixedBasic;
            else 
                WjCell{v} = WjRandomBasic;
            end
        end
        %  Hj and Wj
        stateTranMatrix{j} = blkdiag(HjCell{:});                  %  Done
        stateDistMatrix{j} = cholcov(blkdiag(WjCell{:}));         %  Done
    end


    %  prior mean for x(0): x00
    Mean0 = zeros(d,1);                                           %  Done

    %  prior variance matrix for x(0): P00
    Cov0Cell{1} = diffusePrior*eye(2*p);
    for v=2:(n+1)
        Cov0Cell{v} = diag(randomDiag);
    end
    Cov0 = blkdiag(Cov0Cell{:});                                      %  Done

    SSModelStruc.stateTran = stateTranMatrix;
    SSModelStruc.stateDist = stateDistMatrix;
    SSModelStruc.measSens = measSensMatrix;
    SSModelStruc.obseInnov = obseInnovMatrix;
    SSModelStruc.Mean0 = Mean0;
    SSModelStruc.Cov0 = Cov0;

end

