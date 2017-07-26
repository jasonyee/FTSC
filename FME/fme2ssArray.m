%% fme2ssArray
%  fme2ssArray generates a structure array of state-space models (parallel)

function SSMArray = fme2ssArray(nSubj, OBtime, ...
                       fixedArray, randomArray, logparahat, diffusePrior)
%Input:
%   -nSubj is the number of all subjects
%   -OBtime: (t) is the time at observation t.
%   -fixedArray: 1-by-p array stands for fixed effect factors.
%   -randomArray: 1-by-q array stands for random effect factors.
%   -logparahat: the MLE for the cluster.   
%Output:
%   -SSMArray: a nSubj-by-1 structure array,
%       SSMArray(i) is a SSM structure for i subjects

    SSMArray = repmat(struct, nSubj, 1);
    %parfor i=1:nSubj
    for i=1:nSubj
        SSMArray(i) = fme2ss(i, fixedArray, randomArray, OBtime, logparahat, diffusePrior);
    end
end

