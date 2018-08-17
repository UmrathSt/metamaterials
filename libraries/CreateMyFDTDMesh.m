function [CSX, mesh] = CreateMyFDTDMesh(CSX, sGeom, tbm);
% Create the FDTD mesh.x mesh.y and mesh.y
% from the cell array sGeom holding general information
% and the structure tbm holding meshlines in x,y and z-direction
% tbm.x, tbm.y, tbm.z and the total thickness of the structure in
% z-direction tbm.TotalThickness
UClx = sGeom.UCDim(1);
UCly = sGeom.UCDim(2);
mesh.x = [-UClx/2, tbm.x, UClx/2];
mesh.y = [-UClx/2, tbm.y, UClx/2];
% decide size of the simulation volume in z-direction by checking,
% whether the geometry is grounded or not
zmin = 0;
lz_structure = tbm.TotalThickness;
PMLdirections = [0, 0, 0, 0, 0, 8];
if strcmp(sGeom.grounded, 'False');
    zmin = -sGeom.z_size;
    PMLdirections = [0, 0, 0, 0, 8, 8];
    while abs(zmin/sGeom.maxres.z) < 17;
        zmin = zmin-sGeom.maxres.z;
    end;
end;
zmax = lz_structure+sGeom.z_size;
while (zmax-lz_structure)/sGeom.maxres.z < 17;
    zmax = zmax + sGeom.maxres.z;
end;
maxres = sGeom.maxres;
mesh.x = SmoothMeshLines(mesh.x, maxres.x, 1.4);
mesh.y = SmoothMeshLines(mesh.y, maxres.y, 1.4);
mesh.z = SmoothMeshLines([zmin, tbm.z, zmax], maxres.z, 1.4);
CSX = DefineRectGrid(CSX, sGeom.Unit, mesh);
% add materials to the left/right of the structure if necessary
try;
    start = [mesh.x(1), mesh.y(1), mesh.z(end)];
    z_index = find(mesh.z == sGeom.TotalThickness);
    stop  = [mesh.x(end), mesh.y(end), mesh.z(z_index)];
    CSX = AddBox(CSX, sGeom.lMaterial.Name, 1, start, stop);
    
end;
if strcmp(sGeom.grounded, 'False');
    try;
        start = [mesh.x(1), mesh.y(1), mesh.z(1)];
        z_index = find(mesh.z == 0);
        stop  = [mesh.x(end), mesh.y(end), mesh.z(z_index)];
        CSX = AddBox(CSX, sGeom.rMaterial.Name, 1, start, stop);
        catch lasterror;    
    end;
end;

%
if (sGeom.PML == 3);
    mesh = AddPML(mesh, PMLdirections);
end;
end
