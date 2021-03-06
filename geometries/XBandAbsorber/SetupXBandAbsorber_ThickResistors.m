% Setup the XBand absorber simulation
clc;
clear;
addpath('../../libraries');
node = uname.nodename();
Paths.SimBasePath = '/media/stefan/Daten/openEMS/metamaterials/';
if strcmp(node, 'vlinux');
    Paths.SimBasePath = '/mnt/hgfs/E/openEMS/metamaterials/';
end;
Paths.SimPath = 'XBandAbsorberThickResistor';
Paths.SimCSX = 'XBandAbsorber_geometry.xml';
Paths.ResultBasePath = '/home/stefan/Arbeit/openEMS/metamaterials/';
Paths.ResultPath = ['Results/SParameters/XBandAbsorber/' Paths.SimPath];
sim_setup.Paths = Paths;
sim_setup.FDTD.Write = 'True';
sim_setup.FDTD.numThreads = 4;
sim_setup.FDTD.Run = 'True';
sim_setup.FDTD.fstart = 3e9;
sim_setup.FDTD.fstop = 30e9;
sim_setup.FDTD.EndCriteria = 5e-5;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.Geometry.Show = 'True';
sim_setup.Geometry.grounded = 'True';
sim_setup.Geometry.MeshResolution = [40, 40,30];
sim_setup.Geometry.Unit = 1e-3;
UCDim = 14.25;
sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 1e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;
SParameters.ResultFilename = 'lz_3.2_withR_eps_4.1_kappa_0.05_R15_R150';
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
Rwidth = 0.5;
Rthickness = 0.35;
R30 = 15;
R300 = 150;
mRI.Properties.Epsilon= 1;
mRI.Properties.Kappa = 1/Rwidth/R30/sim_setup.Geometry.Unit;
mRI.Name = '30OhmResistor';
mRI.Type = 'Material';

mRO.Properties.Epsilon = 1;
mRO.Properties.Kappa = 1/Rwidth/R300/sim_setup.Geometry.Unit;
mRO.Name = '300OhmResistor';
mRO.Type = 'Material';


mFR4.Name = 'FR4';
mFR4.Type = 'Material';
mFR4.Properties.Kappa = 0.05;
mFR4.Properties.Epsilon = 4.1;
materials{1} = mCu;
materials{2} = mFR4;
materials{3} = mCuSheet;
materials{4} = mRI;
materials{5} = mRO;

% End of material definition
% Define the objects which are made of the defined materials
oCuSlab.Name = 'CopperBackplane';
oCuSlab.MName = 'Cu';
oCuSlab.Type = 'Box';
oCuSlab.Thickness = 1;
oCuSlab.Bstart = [-UCDim/2, -UCDim/2, 0];
oCuSlab.Bstop =  [UCDim/2, UCDim/2, 1];
oCuSlab.Prio = 1;
% inner resistors
oRI.Name = '30OhmResistor';
oRI.MName = '30OhmResistor';
oRI.Type = 'Box';
oRI.Thickness = Rthickness;
oRI.Prio = 5;
oRI.Bstart = [0.5, Rwidth/2, 0];
oRI.Bstop =  [1.2, -Rwidth/2, Rthickness];

oRI2 = oRI;
oRI2.Transform = {'Rotate_Z', pi/2};
oRI3 = oRI;
oRI3.Transform = {'Rotate_Z', pi};
oRI4 = oRI;
oRI4.Transform = {'Rotate_Z', 3*pi/2};
% outer resistors
oRO.Name = '300OhmResistor';
oRO.MName = '300OhmResistor';
oRO.Type = 'Box';
oRO.Thickness = Rthickness;
oRO.Prio = 5;
oRO.Bstart = [+Rwidth/2, -0.35, 0];
oRO.Bstop =  [-Rwidth/2, +0.35, Rthickness];
oRO.Transform =  {'Translate', [2., 0, 0], 'Rotate_Z', pi/4};

oRO2 = oRO;
oRO2.Transform = {'Translate', [2, 0, 0], 'Rotate_Z', pi/4+pi/2};
oRO3 = oRO;
oRO3.Transform = {'Translate', [2, 0, 0], 'Rotate_Z', pi/4+pi};
oRO4 = oRO;
oRO4.Transform ={'Translate', [2, 0, 0], 'Rotate_Z', pi/4+3*pi/2};

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
oFR4Slab.Thickness = 3.2;
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
layer4.Name = 'ResistorPlane';
layer4.objects{1} = oRI;
layer4.objects{2} = oRI2;
layer4.objects{3} = oRI3;
layer4.objects{4} = oRI4;
layer4.objects{5} = oRO;
layer4.objects{6} = oRO2;
layer4.objects{7} = oRO3;
layer4.objects{8} = oRO4;
layer4.Thickness = oRI.Thickness;
%layer3.objects{7} = oRSheetI2;
%layer3.objects{8} = oRSheetI3;
%layer3.objects{9} = oRSheetI4;
%layer3.objects{10} = oRSheetO;
%layer3.objects{11} = oRSheetO2;
%layer3.objects{12} = oRSheetO3;
%layer3.objects{13} = oRSheetO4;
sim_setup.used_layers = {layer1, layer2, layer3, layer4};
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);

