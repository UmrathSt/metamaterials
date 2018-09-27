clc;
clear;

kappa = 0.0;
kappaCarb = 56e6;
eps = 4;
lz = 0;
UCDim = 10;
L = 8;
type_of_sim = {"LEFT","RIGHT"};
ZMESHRES = 40;
MESHRES = 40;

w = UCDim;
with_ring = "True";
for i = 1:length(type_of_sim);
for w = [0.625,1.25,2,2.5];
    lz = 0;
    Carbon_Wiregrid_ring(type_of_sim{i}, UCDim, lz, w, L, eps, kappa, kappaCarb, ZMESHRES,MESHRES);    
end;
end;


