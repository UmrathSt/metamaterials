% Test simulation setup
clc;
clear;
addpath('../');
node = uname.nodename();
Paths.SimBasePath = '/media/stefan/Daten/openEMS/metamaterials/';

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

Paths.SimPath = 'mysim';
Paths.SimCSX = 'mysim_geometry.xml';

Paths.ResultPath = ['Results/SParameters/' Paths.SimPath];
sim_setup.Paths = Paths;
sim_setup.FDTD.Write = 'True';
sim_setup.FDTD.numThreads = 4;
sim_setup.FDTD.Run = 'True';
sim_setup.FDTD.fstart = 3e9;
sim_setup.FDTD.fstop = 30e9;
sim_setup.FDTD.EndCriteria = 1e-6;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.PML = 'PML_8';
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.Geometry.Show = 'True';
sim_setup.Geometry.grounded = 'True';
sim_setup.Geometry.MeshResolution = [40, 40,20];
sim_setup.Geometry.Unit = 1e-3;
UCDim = 14.25;
sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 1e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;
SParameters.ResultFilename = 'dump_kappa_0.05_lz_2';
TDDump.Status = 'False';
FDDump.Status = 'False';
PP.DoSPararmeterDump = 'True';
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
mFR4.Properties.Kappa = 0.05;
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
oCuSlab.Bstart = [-UCDim/2, -UCDim/2, 0];
oCuSlab.Bstop =  [UCDim/2, UCDim/2, 1];
oCuSlab.Prio = 1;
oFSS.Name = 'CopperPolygon';
oFSS.MName = 'CuSheet';
oFSS.Type = 'Polygon';
oFSS.Thickness = 0;
oFSS.Points = [[-2;-2],[1;-2],[2;-1],[2;2],[-2;2]];
oFSS.Prio = 4;
Trafo = {'Rotate_Z', pi/4,'Translate', [-sqrt(2)*2-0.6/sqrt(2),0,0]};
oFSS.Transform = Trafo;
oFSS2 = oFSS;
oFSS3 = oFSS;
oFSS4 = oFSS;
oFSS2.Transform=  {'Rotate_Z', -pi/4,'Translate', [0,sqrt(2)*2+0.6/sqrt(2),0]};
oFSS3.Transform=  {'Rotate_Z', -5*pi/4,'Translate', [0,-sqrt(2)*2-0.6/sqrt(2),0]};
oFSS4.Transform=  {'Rotate_Z', 5*pi/4,'Translate', [sqrt(2)*2+0.6/sqrt(2),0,0]};
oRect.Name = 'CopperRect';
oRect.MName = 'CuSheet';
oRect.Type = 'Polygon';
oRect.Thickness = 0;
oRect.Prio = 4;
oRect.Points = [[-0.5;-0.5],[0.5;-0.5],[0.5;0.5],[-0.5;0.5]];
oFR4Slab.Name = 'FR4Background';
oFR4Slab.MName = 'FR4';
oFR4Slab.Type = 'Box';
oFR4Slab.Thickness = 2;
oFR4Slab.Prio = 2;
oFR4Slab.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4Slab.Bstop = [+UCDim/2, +UCDim/2, oFR4Slab.Thickness];

layer1.Name = 'CuBackPlane';
layer1.objects{1} = oCuSlab;
layer1.Thickness = oCuSlab.Thickness;
layer2.Name = 'FR4Substrate';
layer2.Thickness = oFR4Slab.Thickness;
layer2.objects{1} = oFR4Slab;
layer3.Name = 'FSS';
layer3.Thickness = 0; %ConcuctingSheet!
layer3.objects{1} = oFSS;
layer3.objects{2} = oFSS2;
layer3.objects{3} = oFSS3;
layer3.objects{4} = oFSS4;
layer3.objects{5} = oRect;
sim_setup.used_layers = {layer1, layer2, layer3};
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);

