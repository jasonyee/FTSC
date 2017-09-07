%% Compare KL curve using different algorithms to compute condtitional probabitlity
clear;
clc;

%% Simulation setting
nSim = 1;
nCL = 1;
nCU = 10;
d = nCU - nCL + 1;
diffusePrior = 1e7;

KLCell = {@KL01, @KLCondP, @KLUnif};
AlgoFlag = {'VSS', 'KPVSS'};

BigKL = zeros(d,length(AlgoFlag), length(KLCell));

%% Compute KL distances
for NumC = nCL:nCU

    path_result = 'Y:\Users\Jialin Yi\output\paper simulation\Model Selection\result\';

    load(strcat(path_result, 'simu_result_', num2str(nSim),'_', num2str(NumC),'C.mat'));

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
p.Title = 'KL distance for Simulated Data';
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';

for jj=1:length(KLCell)
    subplot(1,length(KLCell),jj,'Parent',p);
    KLD = BigKL(:,:,jj);
    plot(KLD);
    legend('VSS','KPVSS');
    ylim([64,70]);
    title(func2str(KLCell{jj}))
end
    
    