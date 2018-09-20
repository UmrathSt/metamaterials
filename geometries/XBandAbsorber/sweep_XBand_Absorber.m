
UCDim = 14.25;
fr4_lz = 0;
types_of_sim = {'EXACT'};%,'LEFT','RIGHT'};
mitR = 'True';
R30 = 30;
R300 = 300;
epsFR4 = 1;
kappaFR4 = 0.;
for j = 1:length(types_of_sim);
    type_of_sim = types_of_sim{j};
    Setup_XBandAbsorber(UCDim, fr4_lz, epsFR4, kappaFR4,type_of_sim, mitR, R30, R300);
end;