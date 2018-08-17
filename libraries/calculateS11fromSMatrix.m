function [S11, phase] = calculateS11fromSMatrix(resultfile, Dlz, Depsilon, Dkappa);
% calculate the scattering parameter of a FSS coating on a
% dielctric coating of thickness Dlz based on the 
% results in the filename 'resultfile' which are for a FSS coating on top of
% a dielectric slab of infinite thickness with index N;   
physical_constants;
if (typeinfo(Dlz) == 'matrix');
    error('So far only scalar values of the substrate thickness are implemented');
end;
d = dlmread(resultfile,',',22, 0);
f = d(:,1);
N = sqrt(Depsilon+1j*Dkappa./(2*pi*f*EPS0));
R = d(:,2)+1j*d(:,3);
T = d(:,4)+1j*d(:,5);
phase = exp(1j*2*pi*f.*N*2*Dlz/C0);
S11 = (R - phase) ./ (1 - R.*phase);
end