
UCDim = 7.2;
LZ = linspace(1,3,11);
LL = linspace(3.7,2.5,13);

WG = 0.6
eps = 4.6;
kappa = 0.05;

for lz = [0.4];#[0.6, 0.8];
    for L =[7,6,5,4,3,2];
        SetupRectCuAbsorber(UCDim, L, lz, kappa, eps, ZMESHRES=60,MESHRES=250);
    end;
end;
