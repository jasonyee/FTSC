function [loss_min, NbyN_min] = CostMin(NbyN, cost_mat)
%COSTMIN Minimized cost achieved by a clustering result

N = size(NbyN, 2);
P = perms(1:N);
loss = zeros(1,size(P,1));

for i=1:size(P,1)
    loss_mat = NbyN(:,P(i,:)) .* cost_mat;
    loss(i) = sum(sum(loss_mat));
end

[loss_min, idx] = min(loss);

NbyN_min = NbyN(:,P(idx,:));

end

