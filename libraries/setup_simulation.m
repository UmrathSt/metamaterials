function [retval] = setup_simulation(sim_setup)
% Take the structure simulation_setup and create the simulation files 
% for simulation_setup to simulation_setup{end} in the folder
% if simulation_setup.Paths.SimPath = ',,,/folder.../'
% if simulation_setup.Paths.ResultPath = ',,,/folder.../'
% the following binary variables exist:
%%
% if simulation_setup.Geometry.show = 'True', show the geometry in AppCSXCAD
% if simulation_setup.Geometry.write = 'True', write the geometry file
% if simulation_setup.FDTD.Run = 'True', run the simulation
% if simulation_setup.PP.DumpSParameters = 'True' Dump S-Parameters to the folder ResultPath
% simulation_setup.PP.SParameterFilename = 'S_params_xy';
% if simulation_setup.PP.TDDump.Status = 'True'
% simulation_setup.PP.TDDump.Filename = 'TD_dump_xy'
% if simulation_setup.PP.FDDump.Status = 'True'
% if simulation_setup.PP.FDDump.Frequencies = linspace(1,10,10)*1e9;
% simulation_setup.PP.FDDump.Filename = 'FD_dump_xy'
% simulation_setup.FDTD.fstart = 1e9
% simulation_setup.FDTD.fstop = 10e9;
% simulation_setup.FDTD.EndCriteria = 1e-6;
% simulation_setup.FDTD.Polarization = [1,0,0];
% simulation_setup.FDTD.Kinc = [0,0,-1];
physical_constants;

retval = 'None';
sim_setup.Machine = uname.nodename();
sFDTD = sim_setup.FDTD;
Paths = sim_setup.Paths;
SimPath = Paths.SimPath;
SimCSX = Paths.SimCSX;
ResPath = Paths.ResultPath;
sPP = sim_setup.PP;
sPP.grounded = sim_setup.Geometry.grounded;
sPP.Polarization = sFDTD.Polarization;
sPP.Kinc = sFDTD.Kinc;
sPP.Paths = Paths;
sGeom = sim_setup.Geometry;
sPP.Unit = sGeom.Unit;
FDTD = InitFDTD('EndCriteria', sFDTD.EndCriteria);
fc = 0.5*(sFDTD.fstart+sFDTD.fstop);
fw = 0.5*(sFDTD.fstop-sFDTD.fstart);
sPP.fc = fc;
FDTD = SetGaussExcite(FDTD, fc, fw);
type_of_res = typeinfo(sGeom.MeshResolution);
if strcmp(type_of_res, 'matrix') && length(sGeom.MeshResolution) == 3;
    maxres.x = 3e8/sGeom.MeshResolution(1)/sFDTD.fstop/sGeom.Unit;
    maxres.y = 3e8/sGeom.MeshResolution(2)/sFDTD.fstop/sGeom.Unit;
    maxres.z = 3e8/sGeom.MeshResolution(3)/sFDTD.fstop/sGeom.Unit;
elseif strcmp(type_of_res, 'scalar');
    maxres.z = 3e8/sGeom.MeshResolution/sFDTD.fstop/sGeom.Unit;
    maxres.y = maxres.z;
    maxres.x = maxres.z;  
else;
    error(['Assumed sGeom.MeshResolution to be either a length-3 matrix or scalar, received: ' type_of_res]);
end;
sGeom.maxres = maxres;
sGeom.z_size = C0/sFDTD.fstart/2/sGeom.Unit;
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
[CSX, geomstring, tbm] = AddLayers(CSX, sim_setup.used_layers, 0);
sPP.TotalThickness = tbm.TotalThickness;
sGeom.TotalThickness = sPP.TotalThickness;
runtime = strftime ("%r (%Z) %A %e %B %Y", localtime (time ()));
setupstr = ['# openEMS run on machine ' sim_setup.Machine ' at ' runtime '\n'];
setupstr = horzcat(setupstr, ['# Simulation parameters: Gauss-pulse with fc = '...
             num2str(fc/1e9) ' GHz, fw = ' num2str(fw/1e9) ' GHz, EndCriteria = ' ...
             num2str(sFDTD.EndCriteria) '\n']);
setupstr = horzcat(setupstr, ['# Mesh resolution < lambda_min/' ...
            num2str(sGeom.MeshResolution) '\n']);
setupstr = horzcat(setupstr, ['# Incoming plane wave with k_inc = ' mat2str(sFDTD.Kinc) ...
                ' and polarization = ' mat2str(sFDTD.Polarization) '\n']);
paramstr = horzcat(setupstr,matstring, geomstring);

% CreateMesh
[CSX, mesh] = CreateMyFDTDMesh(CSX, sGeom, tbm);
% definePorts
[CSX, Port, sPP, portstr] = definePorts(CSX, mesh, sPP);
sPP.ParamStr = horzcat(paramstr, portstr);

%fprintf(['\n' sPP.ParamStr]);
% defineDumps
if strcmp(sPP.TDDump.Status, 'True') || strcmp(sPP.FDDump.Status, 'True');
    CSX = defineFieldDumps(CSX, sPP, mesh);
end;
% WriteCSX
if strcmp(sFDTD.Write, 'True');
    exists = exist([Paths.SimBasePath Paths.SimPath]);
    if exists == 7;
        WriteOpenEMS([Paths.SimBasePath Paths.SimPath '/' Paths.SimCSX], FDTD, CSX);
    elseif exists == 0;
         [status, message, mid] = mkdir([Paths.SimBasePath Paths.SimPath]) % create empty simulation folder
    end;
    WriteOpenEMS([Paths.SimBasePath Paths.SimPath '/' Paths.SimCSX], FDTD, CSX);
end;
% show geometry or not
if strcmp(sGeom.Show, 'True');
    CSXGeomPlot([Paths.SimBasePath Paths.SimPath '/' Paths.SimCSX]);
end;
% RunOpenEMS
if strcmp(sFDTD.Run, 'True');
    openEMS_opts = ['--engine=multithreaded --numThreads=' num2str(sFDTD.numThreads)];%'-vvv';
    %Settings = ['--debug-PEC', '--debug-material'];
    Settings = [''];
    RunOpenEMS([Paths.SimBasePath Paths.SimPath], Paths.SimCSX, openEMS_opts, Settings);
end;
% do PostProcessing
if strcmp(sPP.DoSPararmeterDump, 'True');
    [port] = DoS11Dump(Port, sPP);
end;

    

end