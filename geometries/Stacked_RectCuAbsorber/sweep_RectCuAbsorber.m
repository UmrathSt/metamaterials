clc;
clear;


kappaFR4 = 0.;
epsFR4 = 1;
lzRubber = 1.5;
lzFR4 = 2;
UCDim = 8;
L = linspace(3, 3.95, 20);
type_of_sim = {"LEFTRIGHT"};
ZMESHRES = 30;
MESHRES = 300;
for edgeL = [6.8];
    for i = 1:length(type_of_sim);
        RectCuAbsorber(type_of_sim{i}, UCDim, lzRubber, edgeL, epsFR4, kappaFR4,ZMESHRES);
    end;
end;
