% Setup a dielectric FR4 slab simulation
clc;
clear;
addpath('../../libraries');
physical_constants;
node = uname.nodename();
% setup the system paths
Paths.SimPath = 'DielectricSlabStack';
Paths.SimCSX = 'DielectricSlab_geometry.xml';
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
sim_setup.FDTD.EndCriteria = 5e-5;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.FDTD.PML = 'PML_8';
sim_setup.Geometry.Show = 'True';
sim_setup.Geometry.grounded = 'True';
sim_setup.Geometry.MeshResolution = [20, 20,40];
sim_setup.Geometry.Unit = 1e-3;
UCDim = 14.25;
sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 1e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;
SParameters.ResultFilename = '3.2_FR4_EPS2_B';
TDDump.Status = 'False';
FDDump.Status = 'False';
PP.DoSPararmeterDump = 'True';
PP.TDDump = TDDump;
PP.FDDump = FDDump;
PP.SParameters = SParameters;
sim_setup.PP = PP;
% Define the materials which are used:
mFR4.Name = 'FR4';
mFR4.Type = 'Material';
mFR4.Properties.Kappa = 0.05;
mFR4.Properties.Epsilon = 4.6;
mEPS2.Name = 'EPS2';
mEPS2.Type = 'Material';
mEPS2.Properties.Kappa = 0.;
mEPS2.Properties.Epsilon = 2;
materials{1} = mFR4;
materials{2} = mEPS2;
rMaterial = mEPS2;
rEpsilon = rMaterial.Properties.Epsilon;
rKappa = rMaterial.Properties.Kappa;
%sim_setup.PP.lEpsilon = rMaterial.Properties.Epsilon;
%sim_setup.PP.lKappa   = rMaterial.Properties.Kappa;
%sim_setup.Geometry.lMaterial = rMaterial;
fc = (sim_setup.FDTD.fstart+sim_setup.FDTD.fstop)/2;

%sim_setup.PP.rindex = sqrt(rEpsilon+1j*rKappa/(2*pi*fc*EPS0)); 

% End of material definition
% Define the objects which are made of the defined materials
oFR4Slab.Name = 'FR4Background';
oFR4Slab.MName = 'FR4';
oFR4Slab.Type = 'Box';
oFR4Slab.Thickness = 3.2;
oFR4Slab.Prio = 5;
oFR4Slab.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4Slab.Bstop = [+UCDim/2, +UCDim/2, oFR4Slab.Thickness];

oEPS2Slab.Name = 'EPS2Slab';
oEPS2Slab.MName = 'EPS2';
oEPS2Slab.Type = 'Box';
oEPS2Slab.Thickness = 3.2;
oEPS2Slab.Prio = 5;
oEPS2Slab.Bstart = [-UCDim/2, -UCDim/2, 0];
oEPS2Slab.Bstop = [+UCDim/2, +UCDim/2, oEPS2Slab.Thickness];

layer1.Name = 'FR4Substrate';
layer1.Thickness = oFR4Slab.Thickness;
layer1.objects{1} = oFR4Slab;
layer2.Name = 'EPS2Substrate';
layer2.Thickness = oEPS2Slab.Thickness;
layer2.objects{1} = oEPS2Slab;

sim_setup.used_layers = {layer2,layer1}; % radiation first incident on right-most layer
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);

