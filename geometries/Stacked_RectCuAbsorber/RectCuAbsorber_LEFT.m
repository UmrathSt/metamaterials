% Setup a dielectric FR4 slab simulation
clc;
clear;
addpath('../../libraries');
physical_constants;
node = uname.nodename();
% setup the system paths
Paths.SimPath = 'Stacked_RectCuAbsorber';
Paths.SimCSX = 'RectCuAbsorber_geometry.xml';
Paths = configureSystemPaths(Paths, node);
addpath([Paths.ResultBasePath 'libraries/']);
Paths.ResultPath = ['Results/SParameters/' Paths.SimPath];
sim_setup.Paths = Paths; 
%-----------------system path setup END---------------------------------------|
sim_setup.Paths = Paths;
sim_setup.FDTD.Write = 'True';
sim_setup.FDTD.numThreads = 4;
sim_setup.FDTD.Run = 'True';
sim_setup.FDTD.fstart = 4e9;
sim_setup.FDTD.fstop = 40e9;
sim_setup.FDTD.EndCriteria = 5e-5;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.FDTD.PML = 'MUR';
sim_setup.Geometry.Show = 'False';
sim_setup.Geometry.grounded = 'True';
sim_setup.Geometry.MeshResolution = [140, 140,60];
sim_setup.Geometry.Unit = 1e-3;
UCDim = 4;
L1 = 3.9;%3.6
L2 = 3.7;
L3 = 3.5;
lz1 = 1.4; % Schichtdicke vor Kupferrückwand
lz2 = 1.2;
lz3 = 1.2;
kappa = 0.5;
eps = 2;
sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 10e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;

#SParameters.ResultFilename = ['UCDim_' num2str(UCDim) '_L_' num2str(L) '_lz_' num2str(lz) '_eps_' num2str(eps) '_kappa_' num2str(kappa)];
SParameters.ResultFilename = 'backed';
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
mFR4.Properties.Kappa = kappa;
mFR4.Properties.Epsilon = eps;
mCuSheet.Name = 'CuSheet';
mCuSheet.Type = 'ConductingSheet';
mCuSheet.Properties.Thickness = 18e-6;
mCuSheet.Properties.Kappa = 56e6;
materials{1} = mFR4;
materials{2} = mCuSheet;
rMaterial = mFR4;
%rEpsilon = rMaterial.Properties.Epsilon;
%rKappa = rMaterial.Properties.Kappa;
%sim_setup.PP.rEpsilon = rMaterial.Properties.Epsilon;
%sim_setup.PP.rKappa   = rMaterial.Properties.Kappa;
%sim_setup.Geometry.rMaterial = rMaterial;
fc = (sim_setup.FDTD.fstart+sim_setup.FDTD.fstop)/2;

%sim_setup.PP.rindex = sqrt(rEpsilon+1j*rKappa/(2*pi*fc*EPS0)); 

% End of material definition
% Define the objects which are made of the defined materials
oFR4Slab.Name = 'FR4Background';
oFR4Slab.MName = 'FR4';
oFR4Slab.Type = 'Box';
oFR4Slab.Thickness = lz1;
oFR4Slab.Prio = 2;
oFR4Slab.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4Slab.Bstop = [+UCDim/2, +UCDim/2, oFR4Slab.Thickness];
oFR4Slab2.Name = 'FR4Background';
oFR4Slab2.MName = 'FR4';
oFR4Slab2.Type = 'Box';
oFR4Slab2.Thickness = lz2;
oFR4Slab2.Prio = 2;
oFR4Slab2.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4Slab2.Bstop = [+UCDim/2, +UCDim/2, oFR4Slab2.Thickness];

oFR4Slab3.Name = 'FR4Background';
oFR4Slab3.MName = 'FR4';
oFR4Slab3.Type = 'Box';
oFR4Slab3.Thickness = lz3;
oFR4Slab3.Prio = 2;
oFR4Slab3.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4Slab3.Bstop = [+UCDim/2, +UCDim/2, oFR4Slab3.Thickness];
L = L1;
oRect1.Name = 'CopperRect';
oRect1.MName = 'CuSheet';
oRect1.Type = 'Polygon';
oRect1.Thickness = 0;
oRect1.Prio = 4;
oRect1.Points = [[-L/2;-L/2],[L/2;-L/2],[L/2;L/2],[-L/2;L/2]];

oRect2.Name = 'CopperRect';
oRect2.MName = 'CuSheet';
oRect2.Type = 'Polygon';
oRect2.Thickness = 0;
oRect2.Prio = 4;
L = L2;
oRect2.Points = [[-L/2;-L/2],[L/2;-L/2],[L/2;L/2],[-L/2;L/2]];

oRect3.Name = 'CopperRect';
oRect3.MName = 'CuSheet';
oRect3.Type = 'Polygon';
oRect3.Thickness = 0;
oRect3.Prio = 4;
L = L3;
oRect3.Points = [[-L/2;-L/2],[L/2;-L/2],[L/2;L/2],[-L/2;L/2]];

layer2.Name = 'FR4Substrate';
layer2.Thickness = oFR4Slab3.Thickness;
layer2.objects{1} = oFR4Slab3;
layer1.Name = 'FSS';
layer1.Thickness = 0;
layer1.objects{1} = oRect3;

layer6.Name = 'FR4Substrate';
layer6.Thickness = oFR4Slab.Thickness;
layer6.objects{1} = oFR4Slab;
layer5.Name = 'FSS';
layer5.Thickness = 0;
layer5.objects{1} = oRect1;
layer4.Name = 'FR4Substrate';
layer4.Thickness = oFR4Slab2.Thickness;
layer4.objects{1} = oFR4Slab2;
layer3.Name = 'FSS';
layer3.Thickness = 0;
layer3.objects{1} = oRect2;

sim_setup.used_layers = {layer6, layer5, layer4, layer3,layer2,layer1};
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);

