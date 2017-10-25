function [loss_min, NbyN_min] = BalancedCost(NbyN)
%BALANCEDCOST Balanced cost achieved by a clustering result

N = size(NbyN, 1);
balance_cost = ones(N) - eye(N);

[loss_min, NbyN_min] = CostMin(NbyN, balance_cost);

end

