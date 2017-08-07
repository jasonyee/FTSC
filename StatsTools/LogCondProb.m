%% LogCondProb
%  LogCondProb returns the density of the last subject
%  conditioning on previous subjects given a state space model

function logCondProb = LogCondProb(Algo, allData, SSM, nFixedEffects, nRandomEffects)
%Input: t=1:T
%   -Algo: @BuiltIn / @KalmanAll / @DSSFull / @DSS2Step
%   -allData: (i,t) is the data of subject i at time t.
%   -SSM: the total state-space model for allData(:,:)
%Output:
%   -LogCondProb: the log of density for a new subject conditioning on this cluster.

    if isequal(Algo, @BuiltIn) || isequal(Algo, @KalmanAll)
        
        % fitting vectorized state space model
        [n, ~] = size(allData);
        d = 2*(nFixedEffects + (n-1) * nRandomEffects );
        
        % create SSM for 1:end-1 subjects
        SSMm1.TranMX = SSM.TranMX(1:d, 1:d, :);
        SSMm1.DistMean = SSM.DistMean(1:d, :);
        SSMm1.DistCov = SSM.DistCov(1:d, 1:d, :);
        SSMm1.MeasMX = SSM.MeasMX(1:n-1, 1:d, :);
        SSMm1.ObseCov = SSM.ObseCov(1:n-1, 1:n-1, :);
        SSMm1.StateMean0 = SSM.StateMean0(1:d, :);
        SSMm1.StateCov0 = SSM.StateCov0(1:d, 1:d, :);
        
        % compute logLik for 1:end-1
        logLikm1 = Algo(SSMm1, allData(1:end-1,:));
        % compute logLik for allData
        logCondProb = Algo(SSM, allData) - logLikm1;

    else
        %  fitting dynamic state space model
        [~, KalmanArray] = Algo(SSM, allData);

        logCondProb = KalmanArray(end).logLik;
    end
end