function [retval] = setup_simulation(sim_setup)
% Take the structure simulation_setup and create the simulation files 
% for simulation_setup{1} to simulation_setup{end} in the folder
% if simulation_setup{i}.Paths.SimPath = ',,,/folder.../'
% if simulation_setup{i}.Paths.ResultPath = ',,,/folder.../'
% the following binary variables exist:
%%
% if simulation_setup.Geometry.show = 'True', show the geometry in AppCSXCAD
% if simulation_setup.Geometry.write = 'True', write the geometry file
% if simulation_setup.FDTD.Run = 'True', run the simulation
% if simulation_setup.PP.DumpSParameters = 'True' Dump S-Parameters to the folder ResultPath
% simulation_setup.PP.SParameterFilename = 'S_params_xy';
% if simulation_setup.PP.TDDump = 'True'
% simulation_setup.PP.TDDumpFilename = 'TD_dump_xy'
% if simulation_setup.PP.FDDump = 'True'
% if simulation_setup.PP.FDDumpFrequencies = linspace(1,10,10)*1e9;
% simulation_setup.PP.FDDumpFilename = 'FD_dump_xy'
% simulation_setup.FDTD.fstart = 1e9
% simulation_setup.FDTD.fstop = 10e9;
% simulation_setup.FDTD.EndCriteria = 1e-6;
% simulation_setup.FDTD.Polarization = [1,0,0];
% simulation_setup.FDTD.Kinc = [0,0,-1];
retval = 'None';
sFDTD = sim_setup.FDTD;
sPP = sim_setup.PP;
sGeom = sim_setup.Geometry;
FDTD = InitFDTD('EndCriteria', sFDTD.EndCriteria);
fc = 0.5*(sFDTD.fstart+sFDTD.fstop);
fw = 0.5*(sFDTD.fstop-sFDTD.fstart);
FDTD = SetGaussExcite(FDTD, fc, fw);
maxres = 3e8/sGeom.MeshResolution/sGeom.Unit;
if ~all(sFDTD.Kinc == [0, 0, -1]);
    error('Currently only perpendicular incidence and propagation in -z direction is implemented via boundary conditions');
end;
hpol =  abs(cross(sFDTD.Kinc, sFDTD.Polarization));
BC = ones(1,6)*10;
if norm(sFDTD.Polarization) > 1;
    error(['Polarization is to be normalized and must be in either 0 or 1 direction. Given: ' ...
                        mat2str(sFDTD.Polarization)]);
end;

for i = 1:3;
    if sFDTD.Polarization(i);
        BC(2*i) = 0;
        BC(2*i-1) = 0;
    end;
    if sFDTD.Kinc(i);
        BC(2*i) = 3;
        if strcmp(sGeom.grounded, 'True');
            BC(2*i-1) = 0;
        elseif strcmp(sGeom.grounded, 'False');
            BC(2*i-1) = 3;
        end;
    end;
    if hpol(i);
        BC(2*i) = 1;
        BC(2*i-1) = 1;
    end;
end;
%fprintf(['Using the following boundary conditions: ' mat2str(BC) '\n']);
FDTD = SetBoundaryCond(FDTD, BC);
CSX = InitCSX();
[CSX, matstring] = defineCSXMaterials(CSX, sim_setup.used_materials);
[CSX, geomstring, to_be_meshed] = AddLayers(CSX, sim_setup.used_layers, 0);
runtime = strftime ("%r (%Z) %A %e %B %Y", localtime (time ()));
setupstr = ['# openEMS run on machine: ' uname.nodename ' at ' runtime '\n'];
setupstr = horzcat(setupstr, ['# Simulation parameters: Gauss-pulse with fc = '...
             num2str(fc/1e9) ' GHz, fw = ' num2str(fw/1e9) ' GHz, EndCriteria = ' ...
             num2str(sFDTD.EndCriteria) '\n']);
setupstr = horzcat(setupstr, ['# Mesh resolution < lambda_min/' ...
            num2str(sGeom.MeshResolution) '\n']);
setupstr = horzcat(setupstr, ['# Incoming plane wave with k_inc = ' mat2str(sFDTD.Kinc) ...
                ' and polarization = ' mat2str(sFDTD.Polarization) '\n']);
retval = horzcat(setupstr,matstring, geomstring);
% CreateMesh
% definePorts
% defineDumps
% WriteCSX
% RunOpenEMS
end