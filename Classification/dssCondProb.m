%% dssCondProb [NOT COMPLETED]
%  dssCondProb returns the conditional probability of a new subject
%  given the dynamic state-space model and the prior.

function CondProb = dssCondProb(subdata, prior, subMeasMX, subObseCov)
%Input: t=1:T
%   -subdata: (t) is the data for new subject.
%   -prior is a structure storing the prior info for the new subject.
%       -OneSubTranMX: (:,:,t) is the state transition matrix
%       -OneSubDistMean: (:,t) is the state disturbance mean
%       -OneSubDistCov: (:,:,t) is the state disturbance covariance matrix
%       -OneSubState0: initial state mean
%       -OneSubStateCov0: initial state covariance matrix
%   -subMeasMX: (:,:,t) is the measurement sensitivity matrix
%   -subObseCov: (:,:,t) is the observation innovance covariance matrix
%Output: t=1:T
%   -CondProb: the conditional density function of the new subject.

    objval = ...
        KF(prior.OneSubTranMX, prior.OneSubDistMean, prior.OneSubDistCov, ...
            subMeasMX, subObseCov, subdata, ...
            prior.OneSubState0, prior.OneSubStateCov0, true);
    CondProb = exp(-objval);

end