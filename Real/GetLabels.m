clear;clc;

filepath = 'Y:\Users\Jialin Yi\output\Labels\';

realdata = {'symq5','symq6','symq7','symq8','painsev','urinsev','gupi'};

n = 397;

ClusterLabels = zeros(n, length(realdata));

for i=1:length(realdata)
    load(strcat(filepath, realdata{i}, '.mat'));
    ClusterLabels(:,i) = Labels;
end

csvwrite(strcat(filepath, 'Labels.csv'), ClusterLabels);