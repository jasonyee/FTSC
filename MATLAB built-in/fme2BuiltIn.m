function Md = fme2BuiltIn(n, fixedArray, randomArray, t, logpara, diffusePrior)
%FME2BUILTIN
%   functional mixed effect model -> SSM -> MATLAB's built-in ssm

    SSM = fme2ss(n, fixedArray, randomArray, t, logpara, diffusePrior);
    Md = ss2BuiltIn(SSM);
    
end

