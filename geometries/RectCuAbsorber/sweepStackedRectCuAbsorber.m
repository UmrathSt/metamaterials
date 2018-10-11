
UCDim = 4;
LZ = linspace(1,3,11);
L = [3.65,3.5, 3.35,3.2,3.05,2.9,2.75];

WG = 0.6
eps = 4.6;
kappa = 0.5;

for lz = [0.2,0.4,0.6];#[0.6, 0.8];
    StackedSetupRectCuAbsorber(UCDim, L, lz, kappa, eps, ZMESHRES=60,MESHRES=250);
end;
