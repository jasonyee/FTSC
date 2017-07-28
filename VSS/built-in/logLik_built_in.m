function logL = logLik_built_in(SSM, Y)
%Assume SSM is a state space model structure
%   Y is the data

    [~, T] = size(Y);
    A = cell(1, T);
    B = cell(1, T);
    C = cell(1, T);
    D = cell(1, T);
    data = cell(T, 1);
    for t=1:T
        A{t} = SSM.TranMX(:,:,t);
        B{t} = chol(SSM.DistCov(:,:,t));
        C{t} = SSM.MeasMX(:,:,t);
        D{t} = chol(SSM.ObseCov(:,:,t));
        Mean0 = SSM.StateMean0;
        Cov0 = SSM.StateCov0;
        data{t} = Y(:,t);
    end
    Md = ssm(A, B, C, D, 'Mean0', Mean0, 'Cov', Cov0);
    [~, logL, ~] = filter(Md, data);
end

