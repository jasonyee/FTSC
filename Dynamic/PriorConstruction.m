function [ TranMX, DistMean, DistCov, State0, StateCov0] = ...
    PriorConstruction(Smoothed, SmoothedCov, Smoothed0, SmoothedCov0, ConvMinus)
%PriorConstruction computes the prior information for the next condtional 
%   state-space model

    % initialize the storage
    [d, T] = size(Smoothed);
    TranMX = zeros(d, d, T);
    DistMean = zeros(d, T);
    DistCov = TranMX;
    
    State0 = Smoothed0;
    StateCov0 = SmoothedCov0;
    
    Smoothedt = Smoothed0;
    SmoothedCovt = SmoothedCov0;
    for t=1:T
        
        SmoothedtMinus = Smoothedt;
        SmoothedCovtMinus = SmoothedCovt;
        
        Smoothedt = Smoothed(:,t);
        SmoothedCovt = SmoothedCov(:,:,t);
        
        [TranMX(:,:,t), DistMean(:,t), DistCov(:,:,t)] =...
            PriorConstructionUpdate(Smoothedt,...
                                    SmoothedtMinus,...
                                    SmoothedCovt,...
                                    SmoothedCovtMinus,...
                                    ConvMinus(:,:,t));
    end
    
end

