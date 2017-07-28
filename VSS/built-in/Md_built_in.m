function Md = Md_built_in(n, fixedArray, randomArray, t, logpara, diffusePrior)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    SSM = fme2ss(n, fixedArray, randomArray, t, logpara, diffusePrior);
    T = length(t);
    A = cell(1, T);
    B = cell(1, T);
    C = cell(1, T);
    D = cell(1, T);
    for t=1:T
        A{t} = SSM.TranMX(:,:,t);
        B{t} = chol(SSM.DistCov(:,:,t));
        C{t} = SSM.MeasMX(:,:,t);
        D{t} = chol(SSM.ObseCov(:,:,t));
        Mean0 = SSM.StateMean0;
        Cov0 = SSM.StateCov0;
    end
    Md = ssm(A, B, C, D, 'Mean0', Mean0, 'Cov', Cov0);
end

