function [SpaceMean, SpaceVar] = ...
    SpaceMeanVarTimeInvariant(Output, SSM, AlgoFlag, EstimateFlag)
%SpaceMeanVar extracts the space estimates from the model structure
%   Assume: Output is a Kalman structure.
%           SSM is a state space model structure.
%           AlgoFlag is the flag for different algos: 
%                       -built-in
%                       -kalman-all
%                       -dss-full
%                       -dss-2step
%           EstimateFlag: smooth/filter

    % get states mean and time period
    [StatesMean, ~] = StatesMeanVar(Output, AlgoFlag, EstimateFlag);
    
    switch AlgoFlag
        case 'built-in'
            T = length(Output);
        otherwise
            [n, ~, T] = size(SSM.MeasMX);
    end
    
    switch AlgoFlag
        case 'built-in'
        % Output is a T-by-1 structure array
            for t=T:-1:1
                SpaceMean(:,t) = SSM.C * StatesMean(:,t);
                SpaceVar(:,t) = ...
                    diag(SSM.C * Output(t).SmoothedStatesCov * SSM.C');
            end
            
        case 'kalman-all'
        % Output is a single structure    
            for t=T:-1:1
                SpaceMean(:,t) = SSM.MeasMX(:,:,t) * StatesMean(:,t);
                SpaceVar(:,t) = ...
                    diag(SSM.MeasMX(:,:,t) * Output.SmoothedCov(:,:,t) * SSM.MeasMX(:,:,t)');
            end    
            
        case 'dss-full'
        % Output is a nSubj-by-1 structure array
        % StatesMean is a d-by-T-by-nSubj structure array
            for t=T:-1:1
                SpaceMean(:,t) = SSM.MeasMX(:,:,t) * StatesMean(:,t,n);
                SpaceVar(:,t) = ...
                    diag(SSM.MeasMX(:,:,t) * Output(n).SmoothedCov(:,:,t) * SSM.MeasMX(:,:,t)');
            end   
            
        case 'dss-2step'
        % Output is a 2-by-1 structure array
        % StatesMean is a d-by-T-by-nSubj structure array
            for t=T:-1:1
                SpaceMean(:,t) = SSM.MeasMX(:,:,t) * StatesMean(:,t,2);
                SpaceVar(:,t) = ...
                    diag(SSM.MeasMX(:,:,t) * Output(2).SmoothedCov(:,:,t) * SSM.MeasMX(:,:,t)');
            end  
    end
                    

end

