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
mesh = AddPML(mesh, PMLdirections);
end;
