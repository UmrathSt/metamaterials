f1 = '/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/DielectricSlabStack/S11_3.2_FR4_EPS2_RIGHT';
f2 = '/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/DielectricSlabStack/S11_3.2_FR4_EPS2_LEFT';

dR = dlmread(f1, ',', 15,0);
dL = dlmread(f2, ',', 15,0);

f = dR(:,1);
R = dR(:,2)+1j*dR(:,3);
T= dR(:,4)+1j*dR(:,5);
Rs = dL(:,2)+1j*dL(:,3);
Ts = dL(:,4)+1j*dL(:,5);

plot(f/1e9, abs((T.*Ts).^2), "r-");
hold on;
plot(f/1e9, abs(1-R.^2), "b-");
hold off;
[S11, f, phase] = calculateS11fromSMatrix(f1, f2, 10e-3, 2, 0);
plot(f/1e9, abs(S11).^2,"r-");