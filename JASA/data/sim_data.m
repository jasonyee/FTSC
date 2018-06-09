function [file_name] = sim_data(Path_FEffect, Path_OutputData, paras)
%   'nSim-group_size-var_random1-var_random2-var_random3-var_noise.mat'

nSim = paras(1);
group_size = paras(2);
var_random = paras(3:5);
var_noise = paras(6);

% loading data
load(strcat(Path_FEffect, 'FixedEffect.mat'), 'FixedEffect');

[nGroup, T] = size(FixedEffect);
t = (1:T)/T;
nsamples = nGroup*group_size;

% random effect
RandomEffect = zeros(size(FixedEffect));
for j=1:nGroup
    RandomEffect((j-1)*group_size+1:j*group_size,:) = func_dev(group_size, t, var_random(j));
end

% white noise
WhiteNoise = sqrt(var_noise)*randn(nsamples, T);
% fixed effect
SampleFixedEffect = kron(FixedEffect, ones(group_size,1));

% Truth                 
Y = SampleFixedEffect + RandomEffect + WhiteNoise;
TrueID = kron((1:nGroup)', ones(group_size,1));
TrueMemebers = ClusteringMembers(nGroup, TrueID);

% kmeans
kmeansID = kmeans(Y,nGroup);
kmeansMembers = ClusteringMembers(nGroup, kmeansID);

kmeans_nbyn = table2array(SensTable(TrueMemebers, kmeansMembers));

kmeans_CRate = CRate(kmeans_nbyn, group_size);

kmeans_cost = BalancedCost(kmeans_nbyn);

[~, kmeans_GroupNum] = max(kmeans_nbyn);

kmeans_isSeparated = (length(unique(kmeans_GroupNum)) == nGroup);


file_name = strcat(num2str(nSim), '-', num2str(group_size), '-');
for j=1:length(var_random)
    file_name = strcat(file_name, num2str(var_random(j)), '-');
end
file_name = strcat(file_name, num2str(var_noise));

save(strcat(Path_OutputData, file_name, '.mat'));

end

