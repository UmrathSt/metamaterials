clc;
clear;

kappa = 0.05;
eps = 4.6;
lz = 2;
UCDim = 20;
L = linspace(3, 3.95, 20);
type_of_sim = 'EXACT';

ZMESHRES = 30;
MESHRES = 250;

w = 1;
deltaX = 0.1;

dTheta = 0;
Theta0 = 0;
R1 = 9.8;
w1 = 1.5;
R2 = 5.1;
w2 = 0.5;
for R1 = [9.8];
    for R2 = [5.1];
        for lz = [1, 3];
            SetupDoubleRings(type_of_sim, UCDim, lz, R1, w1, R2, w2, eps, kappa,ZMESHRES=40,MESHRES=80);
            SetupDoubleRings(type_of_sim, UCDim, lz, 0, 0, R2, w2, eps, kappa,ZMESHRES=40,MESHRES=80);
            SetupDoubleRings(type_of_sim, UCDim, lz, R1, w1, 0, 0, eps, kappa,ZMESHRES=40,MESHRES=80);
end; end; end;

