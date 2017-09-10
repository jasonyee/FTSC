function logP = ...
    logCPWrapper(dataset, nClusters, ClusterIDs, ClusterMembers,...
                logLik, logparahat,diffusePrior, AlgoFlag)
%logCPWrapper warps different functions to compute the conditional
%probability

switch AlgoFlag
    
    case 'VSS'
        
        logP =...
    logCPBuiltIn(dataset, nClusters, ClusterIDs, ClusterMembers,...
                logLik, logparahat,diffusePrior, false);
            
    case 'KPVSS'
        
        logP =...
    logCPBuiltIn(dataset, nClusters, ClusterIDs, ClusterMembers,...
                logLik, logparahat,diffusePrior, true);
            
    case 'DSSFull'
        
        logP =...
    logCPDSS(dataset, nClusters, ClusterIDs, ClusterMembers,...
                logparahat,diffusePrior);
end

end

