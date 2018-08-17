function [CSX, port, sPP, portstr] = definePorts(CSX, mesh, sPP);
% define the port(s) for the calculation of S-Parameters
% start and stop coordinates of the active port
physical_constants;
portstr = '';
p1 = [mesh.x(1), mesh.y(1), mesh.z(end-16)];
p2 = [mesh.x(end), mesh.y(end), mesh.z(end-17)];
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
lEpsilon = 1;
lKappa = 0;
try; 
    lEpsilon = sPP.lEpsilon;
    lKappa   = sPP.lKappa;
    portstr = horzcat(portstr,['# Adding material with Epsilon = ' num2str(lEpsilon) ...
                            ' and ' num2str(lKappa) ' on the exitation side of the structure \n']);  
    catch lasterror;
end;
sPP.lKappa = lKappa;
sPP.lEpsilon = lEpsilon;
sPP.LSPort1 = (p2(3)-sPP.TotalThickness)*sPP.Unit;
if strcmp(sPP.grounded, 'False');
    p3 = p2;
    p4 = [mesh.x(1), mesh.y(1), mesh.z(17)];
    [CSX, port{2}] = AddWaveGuidePort(CSX, 10, 2, p3, p4, 2, func_E, func_H, 1, 0);
    % phasefactor has to be multiplied by exp(frequency)
    rEpsilon = 1;
    rKappa = 0;
    try;
        rEpsilon = sPP.rEpsilon;
        rKappa = sPP.rKappa;
        portstr = horzcat(portstr,['# Adding material with Epsilon = ' num2str(rEpsilon) ...
                            ' and ' num2str(rKappa) ' on the transmission side of the structure \n']); 
        catch lasterror;
    end;
    sPP.rKappa = rKappa;
    sPP.rEpsilon = rEpsilon;
    % distance from structure to port 2
    LSPort2 = p4(3)*sPP.Unit;
    sPP.LSPort2 = LSPort2;
end;
end