clc;
clear;


kappaFR4 = 0.;
epsFR4 = 1;
lzRubber = 1.5;
lzFR4 = 2;
UCDim = 16;
L = 6;
w = 1;
type_of_sim = {"EXACT"};
ZMESHRES = 30;
MESHRES = 30;
edgeL = L-w;

for i = 1:length(type_of_sim);
        RectCuAbsorber(type_of_sim{i}, UCDim, lzRubber, edgeL,  L,w, epsFR4, kappaFR4,ZMESHRES, MESHRES);
end;

