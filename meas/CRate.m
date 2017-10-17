function crate = CRate(NbyN, group_size)
%CRATE Clustering rate achieved by a clustering algorithm
%   Detailed explanation goes here

crate = mean(max(NbyN, [], 2))/group_size;

end

