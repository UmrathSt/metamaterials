clc;
clear;

kappa = 0.0;
eps = 1;
lz = 2;
UCDim = 4
L = linspace(3, 3.95, 20);
type_of_sim = {"RIGHT"};
ZMESHRES = 40;
MESHRES = 300;
for edgeL = [4];
    for i = 1:length(type_of_sim);
        RectCuAbsorber(type_of_sim{i}, UCDim, lz, edgeL, eps, kappa,ZMESHRES,MESHRES);
    end;
end;
ZMESHRES = 40;
MESHRES = 200;
type_of_sim = {"EXACT"};
lz = 1;
edgeL = 3.85
for lz = [1];
ZMESHRES = 40;
MESHRES = 200;
for edgeL = [3.95];
    for i = 1:length(type_of_sim);
        RectCuAbsorber(type_of_sim{i}, UCDim, lz, edgeL, eps, kappa,ZMESHRES, MESHRES);
    end;
end;
end;

