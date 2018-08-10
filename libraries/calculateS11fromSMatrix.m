function [S11] = calcS11fromSMatrix(resultfile, Dlz, N);
% calculate the scattering parameter of a FSS coating on a
% dielctric coating of thickness Dlz based on the 
% results in the filename 'resultfile' which are for a FSS coating on top of
% a dielectric slab of infinite thickness with index N;   
if (typeinfo(Dlz) == 'matrix');
    error('So far only scalar values of the substrate thickness are implemented');
end;
d = dlmread(resultfile,',',21,1);
f = d(:,1);
R = d(:,2)+1j*d(:,3);
T = d(:,4)+1j*d(:,5);
phase = exp(-2j*2*pi*f*N*Dlz)
S11 = (R - phase) ./ (1 - R*phase);
end