function [StatesMean, StatesVar] = StatesMeanVar(Output, AlgoFlag, EstimateFlag)
%StatesMeanVar extracts the state estimates from the model structure
%   Assume: Output is a model structure.
%           AlgoFlag is the flag for different algos: 
%                       -built-in
%                       -kalman-all
%                       -dss-full
%                       -dss-2step
%           EstimateFlag: smooth/filter

    switch AlgoFlag
        case 'built-in'
            T = length(Output);
            
            switch EstimateFlag
                case 'smooth'
                    for t=T:-1:1
                        StatesMean(:, t) = Output(t).SmoothedStates;
                        StatesVar(:, t) = diag(Output(t).SmoothedStatesCov);
                    end
                    
                case 'filter'
                    for t=T:-1:1
                        StatesMean(:, t) = Output(t).FilteredStates;
                        StatesVar(:, t) = diag(Output(t).FilteredStatesCov);
                    end
                    
            end
            
            
        case 'kalman-all'
            
            switch EstimateFlag
                case 'smooth'
                    [~, T] = size(Output.Smoothed);
                    StatesMean = Output.Smoothed;
                    for t=T:-1:1
                        StatesVar(:, t) = diag(Output.SmoothedCov(:,:,t));
                    end
                    
                case 'filter'
                    [~, T] = size(Output.Filtered);
                    StatesMean = Output.Filtered;
                    for t=T:-1:1
                        StatesVar(:, t) = diag(Output.FilteredCov(:,:,t));
                    end
            end
            
            
        case 'dss-full'
            n = length(Output);
            [~, T] = size(Output(1).Filtered);
            
            switch EstimateFlag
                case 'smooth'
                    for i=n:-1:1
                        StatesMean(:,:,i) = Output(i).Smoothed;
                        for t=T:-1:1
                            StatesVar(:,t,i) = diag(Output(i).SmoothedCov(:,:,t));
                        end
                    end
                    
                case 'filter'
                    for i=n:-1:1
                        StatesMean(:,:,i) = Output(i).Filtered;
                        for t=T:-1:1
                            StatesVar(:,t,i) = diag(Output(i).FilteredCov(:,:,t));
                        end
                    end
            end
            
            
        case 'dss-2step'
            [~, T] = size(Output(1).Filtered);
            
            switch EstimateFlag
                case 'smooth'
                    for i=2:-1:1
                        StatesMean(:,:,i) = Output(i).Smoothed;
                        for t=T:-1:1
                            StatesVar(:,t,i) = diag(Output(i).SmoothedCov(:,:,t));
                        end
                    end
                    
                case 'filter'
                    for i=2:-1:1
                        StatesMean(:,:,i) = Output(i).Filtered;
                        for t=T:-1:1
                            StatesVar(:,t,i) = diag(Output(i).FilteredCov(:,:,t));
                        end
                    end
            end
    end
                    

end

