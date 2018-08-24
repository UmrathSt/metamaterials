clc;
clear;

kappa = 0.05;
eps = 4.6;
lz = 1;
UCDim = 4
L = linspace(3, 3.95, 20);
type_of_sim = {"LEFT", "RIGHT"};
ZMESHRES = 40;
MESHRES = 200;
for edgeL = L;
    for i = 1:length(type_of_sim);
        RectCuAbsorber(type_of_sim{i}, UCDim, lz, edgeL, eps, kappa,ZMESHRES, MESHRES);
    end;
end;


