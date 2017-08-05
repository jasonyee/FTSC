function [ TranMX, DistMean, DistCov ] = ...
    PriorConstructionUpdate( Smoothedt, SmoothedtMinus, SmoothedCovt, SmoothedCovtMinus, ConvtMinus )
%PriorConstructionUpdate is one-step update in PriorConstruction

    TranMX = SmoothedCovt * ConvtMinus' / SmoothedCovtMinus;
    
    DistMean = Smoothedt - TranMX * SmoothedtMinus;
    
    DistCov = SmoothedCovt - TranMX * SmoothedCovtMinus * TranMX';

end

