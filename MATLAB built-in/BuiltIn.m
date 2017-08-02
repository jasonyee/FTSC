function [logL, Output] = BuiltIn(SSM, Y)
%Assume SSM is a State Space Model structure
%   Y is the data


    Md = ss2BuiltIn(SSM);
    
    [~, T] = size(Y);
    data = cell(T, 1);
    
    for t=1:T
        data{t} = Y(:,t); 
    end
    
    [~, logL, Output] = filter(Md, data);
    
end

