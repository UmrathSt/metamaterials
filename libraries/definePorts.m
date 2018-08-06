function [CSX, port] = definePorts(CSX, mesh, sPP);
% define the port(s) for the calculation of S-Parameters
% start and stop coordinates of the active port
p1 = [mesh.x(1), mesh.y(1), mesh.z(end-10)];
p2 = [mesh.x(end), mesh.y(end), mesh.z(end-12)];

func_E{1} = 0;
func_E{2} = -1;
func_E{3} = 0;
func_H{1} = 1;
func_H{2} = 0;
func_H{3} = 0;

    func_E{1} = 1;
    func_E{2} = 0;
    func_E{3} = 0;
    func_H{1} = 0;
    func_H{2} = 1;
    func_H{3} = 0;
  end; 
  [CSX, port{1}] = AddWaveGuidePort(CSX, 10, 1, p1, p2, 2, func_E, func_H, 1, 1);
  UC.port1_zcoordinate = p2(end);
  UC.port2_lgth = p1(end)-p4(end);
  [CSX, port{2}] = AddWaveGuidePort(CSX, 10, 2, p3, p4, 2, func_E, func_H, 1, 0);
end


end;