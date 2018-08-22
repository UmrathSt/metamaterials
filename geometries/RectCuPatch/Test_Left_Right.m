f1 = '/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/RectCuPatch/S11_sheet_L_9_lz_RIGHT';
f2 = '/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/RectCuPatch/S11_sheet_L_9_lz_LEFT';

dR = dlmread(f1, ',', 18,0);
dL = dlmread(f2, ',', 18,0);

f = dR(:,1);
R = dR(:,2)+1j*dR(:,3);
T= dR(:,4)+1j*dR(:,5);
Rs = dL(:,2)+1j*dL(:,3);
Ts = dL(:,4)+1j*dL(:,5);

plot(f/1e9, abs(R.^2)+abs(T.^2), "r-");
hold on;
plot(f/1e9, abs(Rs.^2)+abs(Ts.^2), "b-");