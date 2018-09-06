function CSX = defineFieldDumps(CSX, sPP, mesh)
% set up the time-domain and/or frequency domain dumps

if strcmp(sPP.TDDump.Status, 'True');
    CSX = AddDump(CSX, 'Etxz');
    CSX = AddBox(CSX, 'Etxz', 1, [mesh.x(1), 0, mesh.z(1)], [mesh.x(end), 0, mesh.z(end)]);
end;

end