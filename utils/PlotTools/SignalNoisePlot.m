function SignalNoisePlot(data_struct, SimID, LineStyles, LineColors)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

group_size = data_struct.group_size;
nClusters = data_struct.nClusters;

FixedEffect = data_struct.SampleFixedEffect(:,:,SimID);
RandomEffect = data_struct.RandomEffect(:,:,SimID);
WhiteNoise = data_struct.WhiteNoise(:,:,SimID);

Signals = FixedEffect + RandomEffect;

RawData = data_struct.data(:,:,SimID);

var_random = data_struct.var_random;
var_noise = data_struct.var_noise;
nSim = data_struct.nSim;


figure;
for j=1:nClusters
    group_raw_data = RawData((j-1)*group_size+1:j*group_size,:);
    plot(group_raw_data', 'LineStyle', LineStyles{j}, 'Color', LineColors{j});
    hold on
end
title(strcat('Random effect:', string(var_random), {' '}, 'Noise: ', num2str(var_noise)))

end

