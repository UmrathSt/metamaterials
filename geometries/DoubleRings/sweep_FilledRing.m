clc;
clear;

kappa = 0.05;
kappaFSS = 4000;
eps = 4.6;
lz = 2;
UCDim = 10;
L = linspace(3, 3.95, 20);
type_of_sim = 'EXACT';
ZMESHRES = 30;
MESHRES = 300;
w = 1;
deltaX = 0.1;
R = 4.5;
dTheta = 0;
Theta0 = 0;
for kappaFSS = [2500];
for UCDim = [10];#,9,8,7,6,5];
    for R = [4.85];#UCDim/2-(0:3)*deltaX-0.15;
        for w = [0.2];#(11:min(idivide(R,deltaX), 20))*deltaX
            SetupFilledRing(type_of_sim, UCDim, lz, R, w, dTheta, Theta0, eps, kappa, kappaFSS, ZMESHRES,MESHRES);
            %fprintf('UCDim=%.1f, R=%.2f, w=%.2f\n', UCDim, R, w);
        end;
    end;
end;
end;
