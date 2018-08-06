function [CSX, port, sPP] = definePorts(CSX, mesh, sPP);
% define the port(s) for the calculation of S-Parameters
% start and stop coordinates of the active port
p1 = [mesh.x(1), mesh.y(1), mesh.z(end-10)];
p2 = [mesh.x(end), mesh.y(end), mesh.z(end-12)];
Einc = sPP.Polarization;
Einc = Einc/norm(Einc);
Kinc = sPP.Kinc;
Kinc = Kinc/norm(Kinc);
Hinc = cross(Kinc, Einc);
for i = 1:3;
    func_E{i} = Einc(i);
    func_H{i} = Hinc(i);
end;

[CSX, port{1}] = AddWaveGuidePort(CSX, 10, 1, p1, p2, 2, func_E, func_H, 1, 1);
% phasefactor has to be multiplied by exp(frequency)
sPP.S11PhaseFactor = exp(2*Pi*1j*/C0*(p2(3)-sPP.TotalThickness)*2*sPP.Unit*f);
if strcmp(sPP.grounded, 'False');
    p3 = p1;
    p4 = [mesh.x(end), mesh.y(end), mesh.z(10)];
    [CSX, port{2}] = AddWaveGuidePort(CSX, 10, 2, p3, p4, 2, func_E, func_H, 1, 0);
    % phasefactor has to be multiplied by exp(frequency)
    dist = p2(3)-p4(3)-sPP.TotalThickness;
    sPP.S12PhaseFactor = exp(2*Pi*1j*/C0*dist*sPP.Unit*f);
end;
end


end;