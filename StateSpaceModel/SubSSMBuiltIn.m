function SubMd = SubSSMBuiltIn(n, Md)
%SubSSMBuiltIn returns a new ssm that shares the same parameters as
%   Md but with fewer number of subjects.
%Description:
%   Note that all matrix structures in Md are preserved when nSubj is
%   smaller. Hence this function could be used to save the computation cost
%   for reconstructing a Md in clustering.

% get the desired dimensions of the state
d = 2*n+2;

% construct new ssm
A = Md.A(1:d, 1:d);
B = Md.B(1:d, 1:d);
C = Md.C(1:n, 1:d);
D = Md.D(1:n, 1:n);
Mean0 = Md.Mean0(1:d);
Cov0 = Md.Cov0(1:d,1:d);

SubMd = ssm(A, B, C, D, 'Mean0', Mean0, 'Cov0', Cov0);

end

