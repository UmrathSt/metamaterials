clc;
clear;

kappa = 0.5;
eps = 2;
lz = 1;
UCDim = 4
L = linspace(2, 3.9, 20);
type_of_sim = {"LEFT", "RIGHT"};


for edgeL = L;
    for i = 1:length(type_of_sim);
        RectCuAbsorber(type_of_sim{i}, UCDim, lz, edgeL, eps, kappa);
    end;
end;
ZMESHRES = 40;
MESHRES = 200;
type_of_sim = {"EXACT"};
lz = 1.7;
edgeL = 3.8
for lz = [1.6,1.8,1.9];
    for i = 1:length(type_of_sim);
        RectCuAbsorber(type_of_sim{i}, UCDim, lz, edgeL, eps, kappa,ZMESHRES,MESHRES);
    end;
end;
