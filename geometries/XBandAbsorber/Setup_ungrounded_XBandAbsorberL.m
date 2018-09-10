% Setup the XBand absorber simulation
clc;
clear;
physical_constants;
addpath('../../libraries');
node = uname.nodename();
% setup the system paths
Paths.SimPath = 'XBandAbsorber';
Paths.SimCSX = 'XBandAbsorber_ungroundedL_geometry.xml';
Paths = configureSystemPaths(Paths, node);
addpath([Paths.ResultBasePath 'libraries/']);
Paths.ResultPath = ['Results/SParameters/' Paths.SimPath];
sim_setup.Paths = Paths; 
%-----------------system path setup END---------------------------------------|
sim_setup.Paths = Paths;
sim_setup.FDTD.Write = 'True';
sim_setup.FDTD.numThreads = 5;
sim_setup.FDTD.Run = 'True';
sim_setup.FDTD.fstart = 3e9;
sim_setup.FDTD.fstop = 20e9;
fc = (sim_setup.FDTD.fstart+sim_setup.FDTD.fstop)/2;
sim_setup.FDTD.EndCriteria = 5e-5;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.FDTD.PML = 'MUR';
sim_setup.Geometry.Show = 'True';
sim_setup.grounded = 'True';
type_of_sim = 'RIGHT';
ResXY = 140;
mitR = 'False';
lz = 3.2;
if strcmp(type_of_sim,'LEFT') || strcmp(type_of_sim,'RIGHT');
    sim_setup.Geometry.grounded = 'False';
    sim_setup.grounded = 'False';
end;
sim_setup.Geometry.MeshResolution = [ResXY, ResXY,40];
sim_setup.Geometry.Unit = 1e-3;
sim_setup.Geometry.grounded = sim_setup.grounded;
UCDim = 14.25;
sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 1e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;
R30 = 30;
R300 = 300;
Rwidth = 0.5;
SParameters.ResultFilename = ['UCDim_' num2str(UCDim) '_R1_' num2str(R30) '_R2_' num2str(R300) '_' type_of_sim '_' num2str(ResXY) '_40_mitR_' mitR ];
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
mCuSheet.Properties.Thickness = 100e-6;
mCuSheet.Properties.Kappa = 56e6;
Rwidth = 0.5;
mRSheetI.Properties.Thickness = 100e-6;
mRSheetI.Properties.Kappa = 0.6/R30/(Rwidth*sim_setup.Geometry.Unit*0.1);
mRSheetI.Name = '30_OhmResistor';
mRSheetI.Type = 'ConductingSheet';

mRSheetO.Properties.Thickness = 100e-6;
mRSheetO.Properties.Kappa = 0.6/R300/(Rwidth*sim_setup.Geometry.Unit*0.1);
mRSheetO.Name = '300_OhmResistor';
mRSheetO.Type = 'ConductingSheet';


mFR4.Name = 'FR4';
mFR4.Type = 'Material';
mFR4.Properties.Kappa = 0.05;
mFR4.Properties.Epsilon = 4.6;
% take care of the material right of the structure
% where transmission takes place
rMaterial = mFR4;
if strcmp(type_of_sim, 'LEFT');
    lMaterial = mFR4;
    lEpsilon = lMaterial.Properties.Epsilon;
    lKappa = lMaterial.Properties.Kappa;
    sim_setup.PP.lEpsilon = lMaterial.Properties.Epsilon;
    sim_setup.PP.lKappa   = lMaterial.Properties.Kappa;
    sim_setup.Geometry.lMaterial = lMaterial;
elseif strcmp(type_of_sim,'RIGHT');
    rMaterial = mFR4;
    rEpsilon = rMaterial.Properties.Epsilon;
    rKappa = rMaterial.Properties.Kappa;
    sim_setup.PP.rEpsilon = rMaterial.Properties.Epsilon;
    sim_setup.PP.rKappa   = rMaterial.Properties.Kappa;
    sim_setup.Geometry.rMaterial = rMaterial;
end;
fc = (sim_setup.FDTD.fstart+sim_setup.FDTD.fstop)/2;
%

%materials{1} = mCu;
materials{1} = mFR4;
materials{2} = mCuSheet;
if strcmp(mitR, 'True');
    materials{3} = mRSheetI;
    materials{4} = mRSheetO;
end;
if strcmp(type_of_sim, 'EXACT') && strcmp(mitR, 'True');
    materials{5} = mCu;
elseif strcmp(type_of_sim, 'EXACT') && strcmp(mitR, 'False');
    materials{3} = mCu;
end;

% End of material definition
% Define the objects which are made of the defined materials
oCuSlab.Name = 'CopperBackplane';
oCuSlab.MName = 'Cu';
oCuSlab.Type = 'Box';
oCuSlab.Thickness = 1;
oCuSlab.Bstart = [-UCDim/2, -UCDim/2, 0];
oCuSlab.Bstop =  [UCDim/2, UCDim/2, 1];
oCuSlab.Prio = 1;
oRSheetI.Name = '30_OhmResistor';
oRSheetI.MName = '30_OhmResistor';
oRSheetI.Type = 'Polygon';
oRSheetI.Thickness = 0;
oRSheetI.Prio = 4;
oRSheetI.Points = [[0.5;-0.3],[0.5;0.3],[1.2;0.3],[1.2;-0.3]];
oRSheetO.Name = '300_OhmResistor';
oRSheetO.MName = '300_OhmResistor';
oRSheetO.Type = 'Polygon';
oRSheetO.Thickness = 0;
oRSheetO.Prio = 4;
oRSheetO.Points = [[0.5;-0.3],[0.5;0.3],[1.1;0.3],[1.1;-0.3]];
oRSheetO.Transform = {'Translate', [1.5, 0, 0], 'Rotate_Z', pi/4};
oRSheetO2 = oRSheetO;
oRSheetO2.Transform = {'Translate', [1.5, 0, 0], 'Rotate_Z', pi/4+pi/2};
oRSheetO3 = oRSheetO;
oRSheetO3.Transform = {'Translate', [1.5, 0, 0], 'Rotate_Z', pi/4+pi};
oRSheetO4 = oRSheetO;
oRSheetO4.Transform = {'Translate', [1.5, 0, 0], 'Rotate_Z', pi/4+3*pi/2};

oRSheetI2 = oRSheetI;
oRSheetI2.Transform = {'Rotate_Z', pi/2};
oRSheetI3 = oRSheetI;
oRSheetI3.Transform = {'Rotate_Z', pi};
oRSheetI4 = oRSheetI;
oRSheetI4.Transform = {'Rotate_Z', 3*pi/2};
oFR4Slab.Name = 'FR4Background';
oFR4Slab.MName = 'FR4';
oFR4Slab.Type = 'Box';
oFR4Slab.Thickness = lz;
oFR4Slab.Prio = 2;
oFR4Slab.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4Slab.Bstop = [+UCDim/2, +UCDim/2, oFR4Slab.Thickness];
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
if strcmp(mitR, 'True');
    layer3.objects{6} = oRSheetI;
    layer3.objects{7} = oRSheetI2;
    layer3.objects{8} = oRSheetI3;
    layer3.objects{9} = oRSheetI4;
    layer3.objects{10} = oRSheetO;
    layer3.objects{11} = oRSheetO2;
    layer3.objects{12} = oRSheetO3;
    layer3.objects{13} = oRSheetO4;
end;

sim_setup.used_layers = {layer3};

if strcmp(type_of_sim, 'EXACT');
    sim_setup.used_layers = {layer1, layer2, layer3};
end;
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);

