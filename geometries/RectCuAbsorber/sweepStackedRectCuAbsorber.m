
UCDim = 6;
LZ = linspace(1,3,11);
LL1 = [3.85,3.7, 3.55,3.4,3.25,3.1,2.95];+2
LL2 = LL1+0.1;
WG = 0.6
eps = 4.6;
kappa = 0.05;
L = LL2;
for lz = [0.1,0.15,0.2,];#[0.6, 0.8];
    StackedSetupRectCuAbsorber(UCDim, L, lz, kappa, eps, ZMESHRES=120,MESHRES=250);
end;
