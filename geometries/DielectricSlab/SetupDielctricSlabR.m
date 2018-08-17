% Setup a dielectric FR4 slab simulation
clc;
clear;
addpath('../../libraries');
physical_constants;
node = uname.nodename();
Paths.SimBasePath = '/media/stefan/Daten/openEMS/metamaterials/';
Paths.ResultBasePath = '/home/stefan_dlr/Arbeit/openEMS/metamaterials/';
if strcmp(node, 'vlinux');
    Paths.SimBasePath = '/mnt/hgfs/E/openEMS/metamaterials/';
    Paths.ResultBasePath = '/home/stefan/Arbeit/openEMS/metamaterials/';
end;
Paths.SimPath = 'DielectricSlab';
Paths.SimCSX = 'DielectricSlab_geometry.xml';

Paths.ResultPath = ['Results/SParameters/' Paths.SimPath];
sim_setup.Paths = Paths;
sim_setup.FDTD.Write = 'True';
sim_setup.FDTD.numThreads = 6;
sim_setup.FDTD.Run = 'True';
% a too thin PML can result in an oscillation overlaying
% the real S-Parameters of low frequencies are used in the simulation
sim_setup.FDTD.PML = 'PML_12'; % use pml with 8 cells thickness, "2" would be MUR
sim_setup.FDTD.fstart = 3e9;
sim_setup.FDTD.fstop = 20e9;
sim_setup.FDTD.fc = 0.5*(sim_setup.FDTD.fstart+sim_setup.FDTD.fstop);
sim_setup.FDTD.EndCriteria = 1e-6;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.Geometry.Show = 'False';
sim_setup.Geometry.grounded = 'False';
sim_setup.Geometry.MeshResolution = [30, 30, 40];
sim_setup.Geometry.Unit = 1e-3;
UCDim = 6;
sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 1e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;
SParameters.ResultFilename = 'lz_3.2_NEW';
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
mFR4.Properties.Epsilon = 4.6;
mFR4.Properties.Kappa = 0.05;
materials{1} = mFR4;
m2.Name = 'index2material';
m2.Type = 'Material';
m2.Properties.Epsilon = 3;
m2.Properties.Kappa = 0.05;
materials{2} = m2;
rMaterial = m2;
sim_setup.PP.rEpsilon = rMaterial.Properties.Epsilon;
sim_setup.PP.rKappa   = rMaterial.Properties.Kappa;
rEpsilon = rMaterial.Properties.Epsilon;
rKappa = rMaterial.Properties.Kappa;
sim_setup.Geometry.rMaterial = rMaterial;
fc = (sim_setup.FDTD.fstart+sim_setup.FDTD.fstop)/2;

%sim_setup.PP.rindex = sqrt(rEpsilon+1j*rKappa/(2*pi*fc*EPS0)); 

% End of material definition
% Define the objects which are made of the defined materials
oFR4Slab.Name = 'FR4Background';
oFR4Slab.MName = 'FR4';
oFR4Slab.Type = 'Box';
oFR4Slab.Thickness = 3.2;
oFR4Slab.Prio = 2;
oFR4Slab.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4Slab.Bstop = [+UCDim/2, +UCDim/2, oFR4Slab.Thickness];


layer2.Name = 'FR4Substrate';
layer2.Thickness = oFR4Slab.Thickness;
layer2.objects{1} = oFR4Slab;

sim_setup.used_layers = {layer2};
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);

