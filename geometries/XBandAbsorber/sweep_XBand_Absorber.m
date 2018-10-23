
UCDim = 14.25;
fr4_lz = 3.2;
types_of_sim = {'EXACT'};%,'LEFT','RIGHT'};
mitR = 'True';
R30 = 10;
R300 = 10;
epsFR4 = 4.6;
kappaFR4 = 0.05;
for j = 1:length(types_of_sim);
    type_of_sim = types_of_sim{j};
    Setup_XBandAbsorber(UCDim, fr4_lz, epsFR4, kappaFR4,type_of_sim, mitR, R30, R300);
end;