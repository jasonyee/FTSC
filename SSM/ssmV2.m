%% ssmV2
%  ssmV2 creats a a state-space model object in
%  MATLAB@2016a for a univariate state-space model
%  with a nonzero state disturbance mean

%% Assumption
%  -The noise in functional mixed effect model is Gaussian white noise and
%  i.i.d over the time and subject.

function SSModel = ssmV2(stateTranMX, stateDistMean, stateDistVar, measSensMX, obseInnov, Mean0, Cov0)
%  This model is for univariate state space model:
%    d is the dimension of states, m is the # of observations
%  -stateTranMX{j} = H_j: d-by-d
%  -stateDistMean{j} = mu_j: d-by-1
%  -stateDistVar{j} = cholesky(Sigma_j): d-by-d
%  -measSensMX{j} = F_j : 1-by-d
%  -obseInnov{j} = sigma_{j}
%  -Mean0 = E(x(0)): d-by-1
%  -Var0 = Var(x(0)): d-by-d
%  for the detailed mathematics of this algorithms, please refer to:
%       http://www.jstor.org/stable/3068297?seq=1#page_scan_tab_contents

    [foo1, m] = size(stateTranMX);
    [d, f002] = size(Mean0);
    
    %% Initialize 

    stateTransMatrix = cell(1,m);
    stateDistMatrix = cell(1,m);
    measSensMatrix = cell(1,m);
    
    newMean0 = [Mean0; 1];
    newCov0 = blkdiag(Cov0, 0);
    
    for j = 1:m
        stateTransMatrix{j} = [[stateTranMX{j}, stateDistMean{j}];...
                                [zeros(1,d),     1]];
        stateDistMatrix{j} = blkdiag(stateDistVar{j}, 0);
        measSensMatrix{j} = [measSensMX{j}, 0];
    end
    
    SSModel = ssm(stateTransMatrix, stateDistMatrix,...
                  measSensMatrix, obseInnov, ...
                  'Mean0', newMean0, 'Cov0', newCov0);
end

