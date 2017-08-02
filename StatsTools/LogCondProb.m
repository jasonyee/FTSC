%% LogCondProb
%  LogCondProb returns the density of the last subject
%  conditioning on previous subjects given a state space model

function logCondProb = LogCondProb(Algo, allData, SSM)
%Input: t=1:T
%   -Algo: @DSSFull / @DSS2Step
%   -allData: (i,t) is the data of subject i at time t.
%   -SSM: the total state-space model for allData
%Output:
%   -LogCondProb: the log of density for a new subject conditioning on this cluster.

    
    %  fitting dss model
    [~, KalmanArray] = Algo(SSM, allData);
    
    logCondProb = KalmanArray(end).logLik;
end