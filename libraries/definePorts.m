function [CSX, port, sPP, portstr] = definePorts(CSX, mesh, sPP);
% define the port(s) for the calculation of S-Parameters
% start and stop coordinates of the active port
physical_constants;
portstr = '';
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
lindex = 1;
try; 
    lindex = sPP.lindex;
    portstr = horzcat(portstr,['# Adding material with index ' num2str(lindex) ...
                            ' on the excitation side of the structure \n']); 
    catch lasterror;
end;
sPP.S11PhaseFactor = 2*pi*1j/C0*(p2(3)-sPP.TotalThickness)*lindex*2*sPP.Unit;
if strcmp(sPP.grounded, 'False');
    p3 = p2;
    p4 = [mesh.x(1), mesh.y(1), mesh.z(14)];
    [CSX, port{2}] = AddWaveGuidePort(CSX, 10, 2, p3, p4, 2, func_E, func_H, 1, 0);
    % phasefactor has to be multiplied by exp(frequency)
    rindex = 1;
    try;
        rindex = sPP.rindex;
        portstr = horzcat(portstr,['# Adding material with index ' num2str(rindex) ...
                            ' on the transmission side of the structure \n']); 
        catch lasterror;
    end;
    dist = (p2(3)-sPP.TotalThickness)*lindex - p4(3)*rindex;
    sPP.S21PhaseFactor = 2*pi*1j/C0*dist*sPP.Unit;
end;
end