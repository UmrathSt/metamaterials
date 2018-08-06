% Test simulation setup
clc;
clear;
addpath('../');
Paths.SimBasePath = '/media/stefan/Daten/openEMS/metamaterials/';
Paths.SimPath = 'mysim';
Paths.SimCSX = 'mysim_geometry.xml';
Paths.ResultBasePath = '~/Arbeit/openEMS/metamaterials/Results/SParameters/';
Paths.ResultPath = Paths.SimPath;
sim_setup.Paths = Paths;
sim_setup.FDTD.Write = 'True';
sim_setup.FDTD.numThreads = 4;
sim_setup.FDTD.Run = 'True';
sim_setup.FDTD.fstart = 3e9;
sim_setup.FDTD.fstop = 30e9;
sim_setup.FDTD.EndCriteria = 1e-6;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.Geometry.Show = 'True';
sim_setup.Geometry.grounded = 'True';
sim_setup.Geometry.MeshResolution = 30;
sim_setup.Geometry.Unit = 1e-3;
sim_setup.Geometry.UCDim = [10, 10]; % size of the unit-cell in the xy-plane
SParameters.df = 1e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;
TDDump.Status = 'False';
FDDump.Status = 'False';
PP.TDDump = TDDump;
PP.FDDump = FDDump;
PP.SParameters = SParameters;
sim_setup.PP = PP;
% Define the materials which are used:
mCu.Name = 'Cu';
mCu.Type = 'Material';
mCu.Properties.Kappa = 56e6;
mCuSheet.Name = 'CuSheet';
mCuSheet.Type = 'ConductingSheet';
mCuSheet.Properties.Thickness = 18e-6;
mCuSheet.Properties.Kappa = 56e6;
mFR4.Name = 'FR4';
mFR4.Type = 'Material';
mFR4.Properties.Kappa = 0.1;
mFR4.Properties.Epsilon = 4.6;
materials{1} = mCu;
materials{2} = mFR4;
materials{3} = mCuSheet;
% End of material definition
% Define the objects which are made of the defined materials
oCuSlab.Name = 'CopperBackplane';
oCuSlab.MName = 'Cu';
oCuSlab.Type = 'Box';
oCuSlab.Thickness = 1;
oCuSlab.Bstart = [-5, -5, 0];
oCuSlab.Bstop =  [+5, +5, 1];
oCuSlab.Prio = 1;
oFSS.Name = 'CopperPolygon';
oFSS.MName = 'CuSheet';
oFSS.Type = 'Polygon';
oFSS.Thickness = 0;
oFSS.Points = [[0;4],[4;4],[4;0]];
oFSS.Prio = 10;
oFR4Slab.Name = 'FR4Background';
oFR4Slab.MName = 'FR4';
oFR4Slab.Type = 'Box';
oFR4Slab.Thickness = 1;
oFR4Slab.Prio = 1;
oFR4Slab.Bstart = [-5, -5, 0];
oFR4Slab.Bstop =  [+5, +5, oFR4Slab.Thickness];

layer1.Name = 'CuBackPlane';
layer1.objects{1} = oCuSlab;
layer1.Thickness = oCuSlab.Thickness;
layer2.Name = 'FR4Substrate';
layer2.Thickness = oFR4Slab.Thickness;
layer2.objects{1} = oFR4Slab;
layer3.Name = 'FSS';
layer3.Thickness = 0; %ConcuctingSheet!
layer3.objects{1} = oFSS;
sim_setup.used_layers = {layer1, layer2, layer3};
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);

