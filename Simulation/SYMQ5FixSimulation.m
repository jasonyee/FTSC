clear;clc;
% Generating data
% fix random seed
seed = 1;
load('Y:\Users\Jialin Yi\output\SYMQ5\MATLAB\C3\FixedEffect.mat');
group_size = 20;
var_random = 3;
var_noise = 3;

[FTSC_CRate, FTSC_isSeparated, kmeans_CRate, kmeans_isSeparated] = ... 
                    FixSimulation(seed, FixedEffect, group_size, var_random, var_noise);