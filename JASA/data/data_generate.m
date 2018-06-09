%% simulation script for FTSC, output data in following name:
%   'nSim-group_size-var_random1-var_random2-var_random3-var_noise.mat'

clear;clc;
% Specify data I/O
Path_FEffect = 'Y:\Users\Jialin Yi\output\SYMQ5\MATLAB\C3\';
Path_OutputData = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\data\';

Path_OutputCRateCurve = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\CRate_curve\';
Path_OutputCRateBoxplot = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\CRate_boxplot\';

Path_OutputBCostCurve = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\BCost_curve\';
Path_OutputBCostBoxplot = 'Y:\Users\Jialin Yi\output\paper simulation\JASA\BCost_boxplot\';

Plot_filetype = '.pdf';

% Simulation scenario
nSim = 2;
group_size = 10;
var_random = [100, 100, 100];
var_noise = 2;

file_name = strcat(num2str(nSim), '-', num2str(group_size), '-');
for j=1:length(var_random)
    file_name = strcat(file_name, num2str(var_random(j)), '-');
end
file_name = strcat(file_name, num2str(var_noise));


% loading data
load(strcat(Path_FEffect, 'FixedEffect.mat'));

% initializing
data_gen_k_meansSeed = @(seed) ...
    data_gen_k_means(seed, FixedEffect, group_size, var_random, var_noise);

kmeans_CRate = zeros(nSim, 1);
kmeans_isSeparated = zeros(nSim, 1);
kmeans_cost = zeros(nSim, 1);

data = repmat(kron(FixedEffect, ones(group_size,1)), 1, 1, nSim);
SampleFixedEffect = zeros(size(data));
RandomEffect = SampleFixedEffect;
WhiteNoise = RandomEffect;

nClusters = size(FixedEffect,1);
IniClusterIDs_simu = zeros(group_size*nClusters, nSim);

% simulation starts
for i=1:nSim
    [kmeans_CRate(i), kmeans_isSeparated(i), kmeans_cost(i), ...
        data(:,:,i), SampleFixedEffect(:,:,i), RandomEffect(:,:,i), WhiteNoise(:,:,i), ...
        IniClusterIDs_simu(:,i)] = feval(data_gen_k_meansSeed, i*20);
end

% save all variables
save(strcat(Path_OutputData, file_name, '.mat'));


%% Plotting
experiment = 1;
yrange = [-8, 8];
colors = {'r', 'k', 'b'};
subplot(2,2,1)
for q=1:nClusters
    plot(SampleFixedEffect((q-1)*group_size+1:q*group_size,:,experiment)', colors{q});
    hold on
end
ylim(yrange)
title('fixed effect')
subplot(2,2,2)
for q=1:nClusters
    plot(RandomEffect((q-1)*group_size+1:q*group_size,:,experiment)', colors{q});
    hold on
end
ylim(yrange)
title(strcat('random effect var scale', {' '}, num2str(var_random)))
subplot(2,2,3)
for q=1:nClusters
    plot(WhiteNoise((q-1)*group_size+1:q*group_size,:,experiment)', colors{q});
    hold on
end
title(strcat('measurement error var scale', {' '}, num2str(var_noise)))
ylim(yrange)
subplot(2,2,4)
for q=1:nClusters
    plot(data((q-1)*group_size+1:q*group_size,:,experiment)', colors{q});
    hold on
end
title('raw data')
ylim(yrange)
