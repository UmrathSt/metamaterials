clc;
clear;

eps = 4.6;
kappa = 0.05;
lz = [0];linspace(1,3.2,23);
type_of_sim = {'LEFT','RIGHT'};
UCDim = 4;
MeshresXY = 40;
MeshresZ = 80;

for i = 1:length(type_of_sim);
    for LZ = lz;
        SetupDielectricSlab(UCDim, LZ, eps, kappa,  type_of_sim{i}, MeshresXY, MeshresZ);
    end;
end;
