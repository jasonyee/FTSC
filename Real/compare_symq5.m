%% SYMQ5: Compare KL curve using different algorithms to compute condtitional probabitlity
clear;
clc;

%% Simulation setting
nSim = 1;
nCL = 1;
nCU = 1;
d = nCU - nCL + 1;
diffusePrior = 1e7;

KLCell = {@KL01, @KLCondP, @KLUnif};
AlgoFlag = {'VSS', 'KPVSS'};

BigKL = zeros(d,length(AlgoFlag), length(KLCell));

%% Compute KL distances
for NumC = nCL:nCU

    path_result = 'Y:\Users\Jialin Yi\output\SYMQ5\Model Selection\';

    load(strcat(path_result, 'SYMQ5_dif_FC_', num2str(NumC),'C.mat'));

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
p.Title = 'KL distance for SYMQ5';
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';

for jj=1:length(KLCell)
    subplot(1,length(KLCell),jj,'Parent',p);
    KLD = BigKL(:,:,jj);
    plot(KLD);
    legend('VSS','KPVSS');
    ylim([20,30]);
    title(func2str(KLCell{jj}))
end
    
    