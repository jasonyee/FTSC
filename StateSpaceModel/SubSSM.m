function SubSSM = SubSSM(n, SSM)
%SubSSM returns a new SSM that shares the same parameters as
%   SSM but with fewer number of subjects.
%Description:
%   Note that all matrix structures in SSM are preserved when nSubj is
%   smaller. Hence this function could be used to save the computation cost
%   for reconstructing a Md in clustering.

% get the desired dimensions of the state
d = 2*n+2;

SubSSM = struct('TranMX', [], ...
             'DistMean', [], ...
             'DistCov', [], ...
             'MeasMX', [], ...
             'ObseCov', [], ...
             'StateMean0', [], ...
             'StateCov0', []);

% construct new ssm
SubSSM.TranMX = SSM.TranMX(1:d, 1:d, :);
SubSSM.DistMean = SSM.DistMean(1:d,:);
SubSSM.DistCov = SSM.DistCov(1:d, 1:d, :);
SubSSM.MeasMX = SSM.MeasMX(1:n, 1:d, :);
SubSSM.ObseCov = SSM.ObseCov(1:n, 1:n, :);
SubSSM.StateMean0 = SSM.StateMean0(1:d,1);
SubSSM.StateCov0 = SSM.StateCov0(1:d,1:d);

end

