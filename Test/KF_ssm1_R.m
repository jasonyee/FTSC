%% Testing KF using ssm and smooth in MATLAB
%  Adding the corresponding folder to the path

%% Clear
clear;
clc;

rng(1);                                       % control the randomness

%% ********Testing for the provided example in MATLAB*********

T = 30;
n = 1;
t = 1:T;
A = [0 1 0; 1 0 0; 0 0 1];
B = [0.3; 0; 0];
C = [1 -1 0];
D = 0.1;
Mean0 = [0; 0; 1]; 
Cov0 = eye(3);

data = 3*randn(n,T);
TranMX = repmat(A, [1,1,T]);
DistMean = zeros(3,T);
DistCov = repmat(B*B', [1,1,T]);
MeasMX = repmat(C, [1,1,T]);
ObseCov = repmat(D*D', [1,1,T]);


%% Model fitting
tic
KFFit = KF(TranMX, DistMean, DistCov, MeasMX, ObseCov, data, Mean0, Cov0, false);
toc
tic
SMMATLAB = ssm(A,B,C,D,'Mean0',Mean0,'Cov0',Cov0);
toc
%% Filtered estimates .................................PASS

tic
[FilteredMean_MATLAB, logL, output_f ]= filter(SMMATLAB, data');
toc

d = 3;      % state we want to see
figure;
subplot(1,2,1);
plot(t, KFFit.FilteredMean(d,:), t, FilteredMean_MATLAB(:,d));
legend("KFFit","MATLAB");
title("Filtered.Mean");

subplot(1,2,2);
for j=1:T
    FilteredStatesCov_KFFit(j) = KFFit.FilteredCov(d,d,j);
    FilteredStatesCov_MATLAB(j) = output_f(j).FilteredStatesCov(d,d);
end
plot(t,FilteredStatesCov_KFFit, t, FilteredStatesCov_MATLAB);
legend("KFFit","MATLAB");
title("Filtered.Variance");

%% Forecasted stimates ..................PASS

tic
[FilteredMean_MATLAB, logL, output_f ]= filter(SMMATLAB, data');
toc

d = 1;      % state we want to see
figure;
subplot(1,2,1);
for j=1:T
    ForecastedStatesMean_MATLAB(j) = output_f(j).ForecastedStates(d);
end
plot(t, KFFit.ForecastedMean(d,:), t, ForecastedStatesMean_MATLAB);
legend("KFFit","MATLAB");
title("Forecasted.Mean");

subplot(1,2,2);
for j=1:T
    ForecastedStatesCov_KFFit(j) = KFFit.ForecastedCov(d,d,j);
    ForecastedStatesCov_MATLAB(j) = output_f(j).ForecastedStatesCov(d,d);
end
plot(t,ForecastedStatesCov_KFFit, t, ForecastedStatesCov_MATLAB);
legend("KFFit","MATLAB");
title("Forecasted.Variance");