clc;
clear;

kappa = 0.05;
eps = 4.6;
lz = 2;
UCDim = 12;
L = linspace(3, 3.95, 20);
type_of_sim = {"EXACT","LEFT","RIGHT"};
ZMESHRES = 30;
MESHRES = 300;
w = 0.2;
R = 5;
for lz = [2];
    for i = 1:length(type_of_sim);
        SetupDoubleRings(type_of_sim{i}, UCDim, lz, R, w, eps, kappa,ZMESHRES,MESHRES);
    end;
end;
