function [CSX, port, sPP] = definePorts(CSX, mesh, sPP);
% define the port(s) for the calculation of S-Parameters
% start and stop coordinates of the active port
physical_constants;
p1 = [mesh.x(1), mesh.y(1), mesh.z(end-14)];
p2 = [mesh.x(end), mesh.y(end), mesh.z(end-16)];
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
nl = 1;
try; 
    nl = sPP.lindex;
    catch lasterror;
end;
sPP.S11PhaseFactor = 2*pi*1j/C0*(p2(3)-sPP.TotalThickness)*nl*2*sPP.Unit;
if strcmp(sPP.grounded, 'False');
    p3 = p2;
    p4 = [mesh.x(end), mesh.y(end), mesh.z(14)];
    [CSX, port{2}] = AddWaveGuidePort(CSX, 10, 2, p3, p4, 2, func_E, func_H, 1, 0);
    % phasefactor has to be multiplied by exp(frequency)
    nr = 1;
    try;
        nr = sPP.rindex;
        catch lasterror;
    end;
    dist = (p2(3)-sPP.TotalThickness)*nl - p4(3)*nr;
    sPP.S21PhaseFactor = 2*pi*1j/C0*dist*sPP.Unit;
end;
end