%% Optimal number of clusters
%  plot the Kullback-Leibler information distance curve
%  For different dataset, change filename
clear;
clc;

%% Simulation setting
nSim = 1;
nCL = 1;
nCU = 10;
d = nCU - nCL + 1;
diffusePrior = 1e7;

KL = @KL01;

%% preallocation
KLD = zeros(1,d);

%%  Computing the Kullback-Leibler distance for different clustering
for NumC = nCL:nCU
    
    path_result = 'Y:\Users\Jialin Yi\output\paper simulation\KL\result\';
    
    load(strcat(path_result, 'simu_result_', num2str(nSim),'_', num2str(NumC),'C.mat'));
    
    q = NumC - nCL + 1;
    
    %KLD(q) = KL_equal(logP);
    %KLD(q) = KL_CondP(logP);
    KLD(q) = KL(logP);
end

%% KL distance curve and optimal number of clusters

plot(KLD);
[KL_opti, nclusters_opti] = min(KLD);
text = strcat(func2str(KL),' information: The optimal number of clusters is', {' '}, num2str(nclusters_opti));
title(text);

