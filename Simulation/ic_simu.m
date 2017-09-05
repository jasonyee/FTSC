%% Optimal number of clusters
%  plot the Akeika information criterion curve
%  For different dataset, change filename
clear;
clc;

%% Simulation setting
nSim = 1;
nCL = 1;
nCU = 10;
d = nCU - nCL + 1;
diffusePrior = 1e7;

ICCell = {@AIC};

%% Plotting
f = figure;
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = 'Information Criterions for Simulated Data';
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';

for i=1:length(ICCell)

    IC = ICCell{i};

    % preallocation
    InfoCri = zeros(1,d);

    %  Computing the Kullback-Leibler distance for different clustering
    for NumC = nCL:nCU

        path_result = 'Y:\Users\Jialin Yi\output\paper simulation\Model Selection\result\';

        load(strcat(path_result, 'simu_result_', num2str(nSim),'_', num2str(NumC),'C.mat'));

        q = NumC - nCL + 1;

        InfoCri(q) = IC(logLik, logparahat);
    end

    % Information criterion curve and optimal number of clusters
    subplot(1,length(ICCell),i,'Parent',p);
    plot(InfoCri);
    [IC_opti, nclusters_opti] = min(InfoCri);
    text = strcat(func2str(IC),': optimal nClusters', {' '}, num2str(nclusters_opti));
    title(text);
end
