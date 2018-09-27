clc;
clear;


kappaRubber = 0.05;
epsRubber = 4.6;
lzRubber = 2;
UCDim = 16;
L = 4;
w = 1;
type_of_sim = "EXACT";
ZMESHRES = 80;
MESHRES = 40;
edgeL = 7;

for L = linspace(2*w,L,9)
        RectCuAbsorber(type_of_sim, UCDim, lzRubber, edgeL,  L,w, epsRubber, kappaRubber,ZMESHRES, MESHRES);
end;

