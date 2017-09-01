%% Optimal number of clusters
%  plot the Kullback-Leibler information distance curve
%  For different dataset, change filename
clear;
clc;

%% Setting

%  dataset
filename = 'simu';
dataGen = '1_';

%  number of clusters
UNumC = 3;
LNumC = 3;
d = UNumC - LNumC + 1;


diffusePrior = 1e7;

KL = zeros(1,d);

time = zeros(1,d);

%%  Computing the Kullback-Leibler distance for different clustering
for numc = LNumC:UNumC
    
    nc = num2str(numc);
    path = 'C:\Users\jialinyi\Documents\MATLAB\FTSC\Simulation\result\';
    
    load(strcat(path, filename, dataGen, num2str(nc), 'C.mat'));
    
    q = numc - LNumC + 1;
    
    tic;
    KL(q) = ...
        KL_equal(dataset, nClusters, logP);
    time(q) =toc;
end

%% KL distance curve and optimal number of clusters

plot(KL);
[KL_opti, nclusters_opti] = min(KL);
text = strcat('The optimal number of clusters is', {' '}, num2str(nclusters_opti));
title(text);

