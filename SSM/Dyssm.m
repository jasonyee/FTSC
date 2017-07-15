%% Dyssm
%  Dyssm returns the log-likelihood value of dssm and the filtered, 
%  forecasted and smoothed estimate of the states

function output_args = Dyssm(dataset, SSModelStruc, Opti )
%(n is for subjects, m is for observations, d is for states)
%  -datasetis a n-by-m array:
%       (i,j) is the dependent data of the subject i at time j.
%  -SSModelStruc is a structure for state-space object:
%      # SSModelStruc.stateTran{j} is a d-by-d state transition matrix at
%        time j.
%      # SSModelStruc.stateDist{j} is a d-by-d covariance matrix for state
%      disturbance at time j.
%      # SSModelStruc.measSens{j} is a n-by-d transition matrix in the
%      observation equation at time j.
%      # SSModelStruc.obseInnov{j} is a n-by-n cholesky decompoenet of the
%      covariance matrix of the disturbance in the measurement equationa t
%      time j.
%  -Opti is true when the function only returns the log-likelihood value.
%  for more details, please refer to:
%       
    
    %% Initialize
    [n, m] = size(dataset);
    
    Mean0 = SSModelStruc.Mean0;                  % <- E(x^{i-1}(0));
    Cov0 = SSModelStruc.Cov0;                    % <- Var(x^{i-1}(0));
    [d, foo] = size(Mean0);
    
    loglik = 0.0;
    
    stateTranMX = SSModelStruc.stateTran;        % {j} <- H^(i-1)_j
    
    stateDistMean = zeros(d,m);                  % {j} <- mu^{i-1}_j
    stateDistCov = SSModelStruc.stateDist;       % {j} <- cholesky(Sigma^{i-1}_j)
    
    
    measSensMX = cell(1, m);                     % <- F_{i,j}
    obseInnov = cell(1, m);                      % <- sigma^2_{i,j}
    
    StatesFilteredMean = zeros(d,n,m);     % (:,i,j) = m^(i-1)(t_j|t_j)
    StatesFilteredCov = zeros(d,d,n,m);  % (:,:,i,j) = W^(i-1)(t_j|t_j)
    StatesForecastedMean = zeros(d,n,m);     % (:,i,j) = m^(i-1)(t_j|t_{j-1})
    StatesForecastedCov = zeros(d,d,n,m);  % (:,:,i,j) = W^(i-1)(t_j|t_{j-1})
    StatesSmoothedMean = zeros(d,n,m);     % (:,i,j) = m^(i-1)(t_j|Y_i)
    StatesSmoothedCov = zeros(d,d,n,m);  % (:,:,i,j) = W^(i-1)(t_j|Y_i)
    
    %% Sequentially on each subject
    for i=1:n
        OneSubject = dataset(i,:);
        % measurement equation
        for j=1:m
            measSensMX{j} = SSModelStruc.measSens{j}(i,:); 
            obseInnov{j} = SSModelStruc.obseInnov{j}(i,i); 
        end
        
        % construct SSM
        OneSubSSModel = ssmV2(stateTranMX, stateDistMean, stateDistCov, ...
                              measSensMX, obseInnov, Mean0, Cov0);
        
        % filtering and smoothing
        [FilteredX, logL_f, output_f] = filter(OneSubSSModel, OneSubject');
        [SmoothedX, logL_s, output_s] = smooth(OneSubSSModel, OneSubject');
        
        loglik = loglik + logL_f;
        
        % extracting estimates
        for j=1:m
            % filtered
            StatesFilteredMean(:,i,j) = FilteredX(j, 1:end-1);
            jOutput_f = output_f(j);
            StatesFilteredCov(:,:,i,j) = jOutput_f.FilteredStatesCov(1:end-1, 1:end-1);
            % forecasted
            StatesForecastedMean(:,i,j) = jOutput_f.ForecastedStates(1:end-1);
            StatesForecastedCov(:,:,i,j) = jOutput_f.ForecastedStatesCov(1:end-1,1:end-1);
            % smoothed
            StatesSmoothedMean(:,i,j) = SmoothedX(j, 1:end-1);
            jOutput_s = output_s(j);
            StatesSmoothedCov(:,:,i,j) = jOutput_s.SmoothedStatesCov(1:end-1,1:end-1);
        end
        
        % updating
        for j=m:-1:2
            C = StatesFilteredCov(:,:,i,j-1)*stateTranMX{j}'/StatesForecastedCov(:,:,i,j);
            stateTranMX{j} = StatesSmoothedCov(:,:,i,j)*C'/StatesSmoothedCov(:,:,i,j-1);
            stateDistMean(:,j) = StatesSmoothedMean(:,i,j) - stateTranMX{j}*StatesSmoothedMean(:,i,j-1);
            stateDistCov{j} = StatesSmoothedCov(:,:,i,j) - stateTranMX{j}*StatesSmoothedCov(:,:,i,j-1)*stateTranMX{j}';
        end
        C = Cov0*stateTranMX{1}'/StatesForecastedCov(:,:,i,1);
        Mean0 = Mean0 + C*(StatesSmoothedMean(:,i,1) - StatesForecastedMean(:,i,1));
        Cov0 = Cov0 + C*(StatesSmoothedCov(:,:,i,1) - StatesForecastedCov(:,:,i,1))*C';
        
        stateTranMX{1} = StatesSmoothedCov(:,:,i,1)*C'/Cov0;
        stateDistMean(:,1) = StatesSmoothedMean(:,i,1) - stateTranMX{1}*Mean0;
        stateDistCov{1} = StatesSmoothedCov(:,:,i,1) - stateTranMX{1}*Cov0*stateTranMX{1}';
    
    end
    
    
    
    if (Opti)
        output_args = loglik;
    else
        output_args = {loglik, StatesSmoothedMean, StatesSmoothedCov};
    end
        

end

