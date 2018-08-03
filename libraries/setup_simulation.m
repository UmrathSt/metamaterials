function [retval] = setup_simulation(simulation_setup)
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
FDTD = InitFDTD('EndCriteria', UC.EndCriteria);
FDTD = SetGaussExcite(FDTD, 0.5*(UC.f_start+UC.f_stop),0.5*(UC.f_stop-UC.f_start));