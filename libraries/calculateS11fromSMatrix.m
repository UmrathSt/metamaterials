function [S11, f, phase] = calculateS11fromSMatrix(resultfile1,resultfile2, Dlz, Depsilon, Dkappa);
% calculate the scattering parameter of a FSS coating on a
% dielctric coating of thickness Dlz based on the 
% results in the filename 'resultfile' which are for a FSS coating on top of
% a dielectric slab of infinite thickness with index N;   
physical_constants;
if (typeinfo(Dlz) == 'matrix');
    error('So far only scalar values of the substrate thickness are implemented');
end;
d1 = dlmread(resultfile1,',',14, 0);
d2 = dlmread(resultfile2,',',14, 0);
f = d1(:,1);
w = f*2*pi;
[alpha, beta] = calcPropagationConstant(w, Depsilon, Dkappa);
R = d1(:,2)+1j*d1(:,3);
T = d1(:,4)+1j*d1(:,5);
Rs = d2(:,2)+1j*d2(:,3);
Ts = d2(:,4)+1j*d2(:,5);
factor = -j*alpha+beta;
phase = exp(-2*factor*Dlz);
%plot(f/1e9, abs(R).^2,"b-")%;hold on;
%plot(f/1e9, abs(T).^2,"r-");hold on;
%plot(f/1e9, abs(Rs).^2,"b--");hold on;
%plot(f/1e9, abs(Ts).^2,"r--");xlim([4,30]);
S11 = (R + (-1)*Ts.*Rs.*phase) ./ (1 + (-1)*Ts.*Rs.*phase);
S11 = R-T.*Ts.*phase;
end