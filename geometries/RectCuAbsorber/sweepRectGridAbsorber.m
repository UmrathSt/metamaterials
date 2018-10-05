
UCDim = 4;
LZ = [1];
L = [3.8];
W = [0.1,0.15,0.2,0.25,0.3,0.35,0.4];
WG = 0.6
eps = 2.5;
kappa = 0.5;

for lz = LZ;
    for l = L;
        for w = W;
            for g = [WG-w];
                SetupRectGridAbsorber(UCDim, lz, l, w, g, eps, kappa, ZMESHRES=40,MESHRES=350);
            end;
        end;
    end;
end;
