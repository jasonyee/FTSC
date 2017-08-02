function Md = ss2BuiltIn(SSM)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    [~,~,T] = size(SSM.TranMX);
    A = cell(1, T);
    B = cell(1, T);
    C = cell(1, T);
    D = cell(1, T);
    for t=1:T
        A{t} = SSM.TranMX(:,:,t);
        B{t} = chol(SSM.DistCov(:,:,t), 'lower');
        C{t} = SSM.MeasMX(:,:,t);
        D{t} = chol(SSM.ObseCov(:,:,t), 'lower');
    end
    
    Mean0 = SSM.StateMean0;
    Cov0 = SSM.StateCov0;
    
    Md = ssm(A, B, C, D, 'Mean0', Mean0, 'Cov', Cov0);

end

