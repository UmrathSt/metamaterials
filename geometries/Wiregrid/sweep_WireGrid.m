clc;
clear;

kappa = 0;
eps = 1;
lz = 0.25;
UCDim = 10
L = 8;
type_of_sim = {"EXACT"};
ZMESHRES = 30;
MESHRES = 300;
N = 5;
w = 1;
with_ring = "True";
for edgeL = [0.5];
    for i = 1:length(type_of_sim);
        Wiregrid_ring(type_of_sim{i}, UCDim, lz, N, w, L, eps, kappa,with_ring, ZMESHRES);
    end;
end;


