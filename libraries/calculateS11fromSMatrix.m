function [S11, f, phase] = calculateS11fromSMatrix(resultfile1,resultfile2, Dlz, Depsilon, Dkappa);
% calculate the scattering parameter of a FSS coating on a
% dielctric coating of thickness Dlz based on the 
% results in the filename 'resultfile' which are for a FSS coating on top of
% a dielectric slab of infinite thickness with index N;   
physical_constants;
if (typeinfo(Dlz) == 'matrix');
    error('So far only scalar values of the substrate thickness are implemented');
end;
d1 = dlmread(resultfile1,',',18, 0);
d2 = dlmread(resultfile2,',',18, 0);
f = d1(:,1);
w = f*2*pi;
[alpha, beta] = calcPropagationConstant(w, Depsilon, Dkappa);
R = d1(:,2)+1j*d1(:,3);
T = d1(:,4)+1j*d1(:,5);
Rs = d2(:,2)+1j*d2(:,3);
Ts = d2(:,4)+1j*d2(:,5);
factor = -j*alpha+beta;
phase = exp(-2*factor*Dlz);
S11 = R - T.*Ts.*phase./(1+Rs.*phase);
end