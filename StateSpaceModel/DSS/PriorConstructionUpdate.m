function [ TranMX, DistMean, DistCov ] = ...
    PriorConstructionUpdate( Smoothedt, SmoothedtMinus, SmoothedCovt, SmoothedCovtMinus, ConvtMinus )
%PriorConstructionUpdate Summary of this function goes here
%   Detailed explanation goes here

    TranMX = SmoothedCovt * ConvtMinus' / SmoothedCovtMinus;
    
    DistMean = Smoothedt - TranMX * SmoothedtMinus;
    
    DistCov = SmoothedCovt - TranMX * SmoothedCovtMinus * TranMX';

end

