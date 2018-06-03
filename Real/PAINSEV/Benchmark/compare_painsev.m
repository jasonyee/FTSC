%% PAINSEV: Compare KL curve using different algorithms to compute condtitional probabitlity
clear;
clc;

%% Simulation setting
nSim = 1;
nCL = 1;
nCU = 1;
d = nCU - nCL + 1;
diffusePrior = 1e7;

KLCell = {@KL01, @KLCondP, @KLUnif};
AlgoFlag = {'DSSFull'};

BigKL = zeros(d,length(AlgoFlag), length(KLCell));

%% Compute KL distances
for NumC = nCL:nCU

    path_result = 'Y:\Users\Jialin Yi\output\PAINSEV\Model Selection\';

    load(strcat(path_result, 'PAINSEV_dif_FC_', num2str(NumC),'C.mat'));

    q = NumC - nCL + 1;
    
    for ii=1:length(AlgoFlag)
        logCP = ...
            logCPWrapper(dataset, nClusters, ClusterIDs, ClusterMembers,...
                logLik, logparahat,diffusePrior, AlgoFlag{ii});
        for jj=1:length(KLCell)
            KL = KLCell{jj};
            BigKL(q,ii,jj) = KL(logCP);
        end
    end
end

%% Plotting
f = figure;
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = 'KL divergence for PAINSEV';
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';

for jj=1:length(KLCell)
    subplot(1,length(KLCell),jj,'Parent',p);
    KLD = BigKL(:,:,jj);
    plot(KLD);
    legend(AlgoFlag{:});
    ylim([38,43]);
    title(func2str(KLCell{jj}))
end
    
    