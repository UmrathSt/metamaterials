f1 = ['/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/RectCuAbsorber/'...
        'S11_RIGHT'];
f2 = ['/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/RectCuAbsorber/'...
        'S11_LEFT'];
addpath('../../libraries/');
dR = dlmread(f1, ',', 19,0);
dL = dlmread(f2, ',', 19,0);

f = dR(:,1);
R = dR(:,2)+1j*dR(:,3);
T= dR(:,4)+1j*dR(:,5);
Rs = dL(:,2)+1j*dL(:,3);
Ts = dL(:,4)+1j*dL(:,5);

plot(f/1e9, abs((R).^2), "r-");
hold on;
plot(f/1e9, abs(Rs.^2), "b-");
hold off;

[S11, f, phase] = calculateS11fromSMatrix(f1, f2, 1.5e-3, 2, 0.5);
plot(f/1e9, 20*log10(abs(S11)),"r-")