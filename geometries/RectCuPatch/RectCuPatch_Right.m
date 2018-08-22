% Setup the XBand absorber simulation
clc;
clear;
physical_constants;
addpath('../../libraries');
node = uname.nodename();
% setup the system paths
Paths.SimPath = 'RectCuPatch';
Paths.SimCSX = 'RectCuPatch.xml';
Paths = configureSystemPaths(Paths, node);
addpath([Paths.ResultBasePath 'libraries/']);
Paths.ResultPath = ['Results/SParameters/' Paths.SimPath];
sim_setup.Paths = Paths; 
%-----------------system path setup END---------------------------------------|
sim_setup.Paths = Paths;
sim_setup.FDTD.Write = 'True';
sim_setup.FDTD.numThreads = 4;
sim_setup.FDTD.Run = 'True';
sim_setup.FDTD.fstart = 3e9;
sim_setup.FDTD.fstop = 30e9;
fc = (sim_setup.FDTD.fstart+sim_setup.FDTD.fstop)/2;
sim_setup.FDTD.EndCriteria = 5e-5;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.FDTD.PML = 'PML_8';
sim_setup.Geometry.Show = 'True';
sim_setup.Geometry.grounded = 'False';
sim_setup.Geometry.MeshResolution = [40, 40,30];
sim_setup.Geometry.Unit = 1e-3;
UCDim = 10;
sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 1e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;
SParameters.ResultFilename = 'sheet_L_9_lz_RIGHT';
TDDump.Status = 'False';
FDDump.Status = 'False';
PP.DoSPararmeterDump = 'True';
PP.TDDump = TDDump;
PP.FDDump = FDDump;
PP.SParameters = SParameters;
sim_setup.PP = PP;
% Define the materials which are used:

mCuSheet.Name = 'CuSheet';
mCuSheet.Type = 'ConductingSheet';
mCuSheet.Properties.Thickness = 18e-6;
mCuSheet.Properties.Kappa = 56e6;

mFR4.Name = 'FR4';
mFR4.Type = 'Material';
mFR4.Properties.Kappa = 0.05;
mFR4.Properties.Epsilon = 4.6;
% take care of the material right of the structure
% where transmission takes place
rMaterial = mFR4;
sim_setup.PP.rEpsilon = rMaterial.Properties.Epsilon;
sim_setup.PP.rKappa   = rMaterial.Properties.Kappa;
rEpsilon = rMaterial.Properties.Epsilon;
rKappa = rMaterial.Properties.Kappa;
sim_setup.Geometry.rMaterial = rMaterial;
%

%materials{1} = mCu;
materials{2} = mFR4;
materials{1} = mCuSheet;

oRect.Name = 'CopperRect';
oRect.MName = 'CuSheet';
oRect.Type = 'Polygon';
oRect.Thickness = 0;
oRect.Prio = 4;
oRect.Points = [[-4.5;-4.5],[4.5;-4.5],[4.5;4.5],[-4.5;4.5]];

oFR4.Name = 'FR4Substrate';
oFR4.MName = 'FR4';
oFR4.Type = 'Box';
oFR4.Thickness = 0.1;
oFR4.Prio = 3;
oFR4.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4.Bstop = [+UCDim/2, +UCDim/2, oFR4.Thickness];


layer1.Name = 'FR4';
layer1.Thickness = oFR4.Thickness;
layer1.objects{1} = oFR4;
layer2.Name = 'FSS';
layer2.Thickness = 0; %ConcuctingSheet!
layer2.objects{1} = oRect;

sim_setup.used_layers = {layer1,layer2};
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);

