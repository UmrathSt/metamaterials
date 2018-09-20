clc;
clear;

kappa = 0.5;
eps = 2;
lz = 2;
UCDim = 4
L = linspace(3, 3.95, 20);
type_of_sim = {"EXACT"};
ZMESHRES = 30;
MESHRES = 300;
for edgeL = [0.5];
    for i = 1:length(type_of_sim);
        Wiregrid(type_of_sim{i}, UCDim, lz, edgeL, eps, kappa,ZMESHRES);
    end;
end;

type_of_sim = {"EXACT"};
lz = 1;
edgeL = 3;
kappa = 0.5;
eps = 2;
for lz = [3];
ZMESHRES = 40;
MESHRES = 200;
for edgeL = [3.8];
    for i = 1:length(type_of_sim);
        RectCuAbsorber(type_of_sim{i}, UCDim, lz, edgeL, eps, kappa,ZMESHRES);
    end;
end;
end;

