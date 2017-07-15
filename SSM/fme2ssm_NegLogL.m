%% fme2ssm_NegLogL
%  fme2ssm_NegLogL outputs the negative log-likelihood function 0f 
%  a functional mixed effect model with the given dataset using
%  vectorized state space model.

function NegLogL = fme2ssm_NegLogL(dataset, OBtime, logpara, UniOpt)
%This is ONLY for
%   y_{i,j} = beta(t_j) + alpha_i(t_j) + epsilon_{i,j}
%   -dataset is a n-by-m array:
%       dataset(i, t) is the data of subject i at time t.
%   -OBtime is the observation time points, 1-by-m array.
%   -logpara stores the logs of all parameters for optimization.
%       -sigma_e is the ***standard deviation*** of the iid white noise.
%       -lambdaF, lambdaR are the smoothing parameters for
%           fixed effects and random effects.
%       -randomDiag contians the common prior variance parameters for 
%           random effects over all subject i
%           , 2q-by-1.
%   -UniOpt is true when we use the univariate treatment for sequential
%      filtering by Koopman (2003)

p = 1;
q = 1;

%  Model setting
[n, m] = size(dataset);
fixedDesign = repmat(ones(n,p),[1, 1, m]);    % n-by-p-by-m
randomDesign = repmat(ones(n,q),[1, 1, m]);   % n-by-q-by-m

%  Construct state-space model
SSModelStruc = fme2ssm(fixedDesign, randomDesign, OBtime, logpara);

SSModel = ssm(SSModelStruc.stateTran,...
              SSModelStruc.stateDist,...
              SSModelStruc.measSens,...
              SSModelStruc.obseInnov,...
              'Mean0', SSModelStruc.Mean0,...
              'Cov0', SSModelStruc.Cov0);


%  Calculating the logL
[FilteredStates, logL, Output] = filter(SSModel, dataset',...
                                    'Univariate', UniOpt);

NegLogL = -logL;

end