function [ TranMX, DistMean, DistCov ] = ...
    PriorConstructionUpdate( Smoothedt, SmoothedtMinus, SmoothedCovt, SmoothedCovtMinus, ConvtMinus )
%PriorConstructionUpdate update:
%   transition matrix: TranMX d-by-d
%   disturbance mean: DistMean d-by-1
%   disturbance covariance matrix: DistCov d-by-d

    TranMX = SmoothedCovt * ConvtMinus' / SmoothedCovtMinus;
    
    DistMean = Smoothedt - TranMX * SmoothedtMinus;
    
    DistCov = SmoothedCovt - TranMX * SmoothedCovtMinus * TranMX';

end

