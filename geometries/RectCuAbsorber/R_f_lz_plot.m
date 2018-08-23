f1 = ['/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/RectCuAbsorber/'...
        'S11_RIGHT'];
f2 = ['/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/RectCuAbsorber/'...
        'S11_LEFT'];
addpath('../../libraries/');

lz = linspace(0.1,2,200)*1e-3;
dt = dlmread(f1,',',18, 0);
S11 = zeros(length(dt(:,1)),length(lz));

for i = 1:length(lz);
    [S, f, phase] = calculateS11fromSMatrix(f1, f2, lz(i), 2, 0.5); 
    S11(:,i) = S;
end;

min(f)
max(f)
length(lz)
dlmwrite('absS11',abs(S11).^2);