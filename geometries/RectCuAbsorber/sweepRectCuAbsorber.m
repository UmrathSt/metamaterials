
UCDim = 4;
LZ = linspace(1,3,11);
LL = linspace(3.8,2.5,14);

WG = 0.6
eps = 4.6;
kappa = 0.05;

for lz = LZ;
    for L = LL;
        SetupRectCuAbsorber(UCDim, L, lz, kappa, eps, ZMESHRES=60,MESHRES=250);
    end;
end;
