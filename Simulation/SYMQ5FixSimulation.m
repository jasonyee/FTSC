%% Generating data
group_size = 20;
nsamples = 3*group_size;
var_random = 9;
var_noise = 3;
T = 23;
t = (1:T)/T;
MAX_LOOP = 20;
logpara0 = [0.5;6;6;-5;0];

% fix random seed
rng(1);

% random effect
RandomEffect = func_dev(nsamples, t, var_random);
% white noise
WhiteNoise = sqrt(var_noise)*randn(nsamples, T);
% fixed effect
load('Y:\Users\Jialin Yi\output\SYMQ5\MATLAB\C3\FixedEffect.mat');
SampleFixedEffect = [repmat(FixedEffect(1,:),group_size,1);...
                     repmat(FixedEffect(2,:),group_size,1);...
                     repmat(FixedEffect(3,:),group_size,1)];
                 
%% Truth                 
Y = SampleFixedEffect + RandomEffect + WhiteNoise;
TrueID = [ones(group_size,1); 2*ones(group_size,1); 3*ones(group_size,1)];
TrueMemebers = ClusteringMembers(3, TrueID);

%% kmeans
kmeansID = kmeans(Y,3);
kmeansMembers = ClusteringMembers(3, kmeansID);


%% FTSC
IniClusterIDs = kmeansID;
nClusters = 3;
[ClusterIDs, ClusterMembers, SwitchHistory, logparahat, logP, logLik] =...
    SSMBuiltInClustering(Y, nClusters, IniClusterIDs, logpara0, MAX_LOOP);

%% Results
SensTable(TrueMemebers, kmeansMembers)
SensTable(TrueMemebers, ClusterMembers)