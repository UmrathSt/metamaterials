clc;
clear;

kappa = 0;
eps = 1;
lz = 0.5;
UCDim = 4
L = linspace(3, 3.95, 20);
type_of_sim = {"EXACT"};
ZMESHRES = 30;
MESHRES = 300;
for edgeL = [0.5];
    for i = 1:length(type_of_sim);
        Wiregrid_ring(type_of_sim{i}, UCDim, lz, edgeL, eps, kappa,ZMESHRES);
    end;
end;


