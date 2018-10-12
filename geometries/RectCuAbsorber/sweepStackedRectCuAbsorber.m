
UCDim = 10;
LZ = linspace(1,3,11);
LL1 = UCDim*[0.96, 0.93, 0.89, 0.85, 0.81,0.78,0.74];
LL2 = LL1-1;
WG = 0.6
eps = 4.6;
kappa = 05;

for lz = [0.1,0.2,0.3,0.4,0.6];#[0.6, 0.8];
    StackedSetupRectCuAbsorber(UCDim, LL1, lz, kappa, eps, ZMESHRES=60,MESHRES=150);
    StackedSetupRectCuAbsorber(UCDim, LL2, lz, kappa, eps, ZMESHRES=60,MESHRES=150);
end;
