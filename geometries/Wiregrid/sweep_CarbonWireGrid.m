clc;
clear;

kappa = 0.0;
kappaCarb = 200;
eps = 1;
lz = 0;
UCDim = 1;
L = 8;
type_of_sim = {"RIGHT"};
ZMESHRES = 60;
MESHRES = 100;

w = 1;
with_ring = "True";
for w = [2.5];
    type_of_sim = "RIGHT";
    lz = 0;
    %Carbon_Wiregrid_ring(type_of_sim, UCDim, lz, w, L, eps, kappa,kappaCarb, ZMESHRES, MESHRES);
    type_of_sim = "RIGHT";
    lz = 0;
    Carbon_rect(type_of_sim, UCDim, lz, eps, kappa, kappaCarb, ZMESHRES, MESHRES);    
end;



