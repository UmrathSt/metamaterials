clc;
clear;

kappa = 0.05;
eps = 4.6;
lz = 1;
UCDim = 4
L = linspace(2, 3.9,3);
type_of_sim = {"LEFT", "RIGHT"};

for edgeL = L;
    for i = 1:length(type_of_sim);
        RectCuAbsorber(type_of_sim{i}, UCDim, lz, edgeL, eps, kappa);
    end;
end;
