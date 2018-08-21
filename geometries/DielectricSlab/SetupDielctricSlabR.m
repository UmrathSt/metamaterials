% Setup a dielectric FR4 slab simulation
clc;
clear;
physical_constants;
node = uname.nodename();
Paths.SimBasePath = '/media/stefan/Daten/openEMS/metamaterials/';
Paths.ResultBasePath = '/home/stefan_dlr/Arbeit/openEMS/metamaterials/';
fprintf("\n Running on node %s \n", node);
if strcmp(node, 'vlinux');
    Paths.SimBasePath = '/mnt/hgfs/E/openEMS/metamaterials/';
    Paths.ResultBasePath = '/home/stefan/Arbeit/openEMS/metamaterials/';
elseif strcmp(node, 'XPS');
  fprintf('XPS node!!!\n');
    Paths.SimBasePath = '/home/stefan/Arbeit/metamaterials/Daten/';
    Paths.ResultBasePath = '/home/stefan/Arbeit/metamaterials/';
    addpath([Paths.ResultBasePath 'libraries/']);
end;
Paths.SimPath = 'DielectricSlab';
Paths.SimCSX = 'DielectricSlab_geometry.xml';

Paths.ResultPath = ['Results/SParameters/' Paths.SimPath];
sim_setup.Paths = Paths;
sim_setup.FDTD.Write = 'True';
sim_setup.FDTD.numThreads = 4;
sim_setup.FDTD.Run = 'True';
% a too thin PML can result in an oscillation overlaying
% the real S-Parameters of low frequencies are used in the simulation
sim_setup.FDTD.PML = 'PML_12'; % use pml with 8 cells thickness, "2" would be MUR
sim_setup.FDTD.fstart = 4e9;
sim_setup.FDTD.fstop = 30e9;
sim_setup.FDTD.fc = 0.5*(sim_setup.FDTD.fstart+sim_setup.FDTD.fstop);
sim_setup.FDTD.EndCriteria = 1e-6;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.Geometry.Show = 'True';
sim_setup.Geometry.grounded = 'False';
sim_setup.Geometry.MeshResolution = [20, 20, 40];
sim_setup.Geometry.Unit = 1e-3;
UCDim = 6;
sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 1e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;
SParameters.ResultFilename = 'right_double_layer';
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
mFR4.Properties.Kappa = 0.1;
mFR4.Properties.Epsilon = 2;
mTop.Name = 'top';
mTop.Type = 'Material';
mTop.Properties.Kappa = 10;
mTop.Properties.Epsilon = 1;

rMaterial = mFR4;
sim_setup.PP.rEpsilon = rMaterial.Properties.Epsilon;
sim_setup.PP.rKappa   = rMaterial.Properties.Kappa;
rEpsilon = rMaterial.Properties.Epsilon;
rKappa = rMaterial.Properties.Kappa;
sim_setup.Geometry.rMaterial = rMaterial;
fc = (sim_setup.FDTD.fstart+sim_setup.FDTD.fstop)/2;

%sim_setup.PP.rindex = sqrt(rEpsilon+1j*rKappa/(2*pi*fc*EPS0)); 

% End of material definition
% Define the objects which are made of the defined materials


oTopSlab.Name = 'top';
oTopSlab.MName = 'top';
oTopSlab.Type = 'Box';
oTopSlab.Thickness = 1;
oTopSlab.Prio = 1;
oTopSlab.Bstart = [-UCDim/2, -UCDim/2, 0];
oTopSlab.Bstop = [+UCDim/2, +UCDim/2, oTopSlab.Thickness];

layer1.Name = 'TOP';
layer1.Thickness = 1;
layer1.objects{1} = oTopSlab;


sim_setup.used_layers = {layer1};

sim_setup.used_materials = {mFR4, mTop};

retval = setup_simulation(sim_setup);