function RectCuAbsorber(type_of_sim, UCDim, lz, edgeL, L,w, eps, kappa,ZMESHRES=40,MESHRES=140);
% Setup a dielectric FR4 slab simulation
% intended for the calculation of transmission and reflection coefficients
% for varying Cu edge-length in order to minimize the reflection of a stacked structure
addpath('../../libraries');
physical_constants;
node = uname.nodename();
% setup the system paths
Paths.SimPath = 'rubber_absorber';
Paths.SimCSX = 'RectCuAbsorber_geometry.xml';
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
sim_setup.FDTD.fstop = 40e9;
sim_setup.FDTD.EndCriteria = 1e-5;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.FDTD.PML = 'MUR';
sim_setup.Geometry.Show = 'True';
sim_setup.Geometry.grounded = 'True';
if strcmp(type_of_sim,'LEFT') || strcmp(type_of_sim,'RIGHT') || strcmp(type_of_sim,'LEFTRIGHT');
    sim_setup.Geometry.grounded = 'False';
end;
sim_setup.Geometry.MeshResolution = [MESHRES,MESHRES,ZMESHRES];
sim_setup.Geometry.Unit = 1e-3;

sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 10e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;

SParameters.ResultFilename = ['UCDim_' num2str(UCDim) '_edgeL_' num2str(edgeL) '_L_' num2str(L) '_w_' num2str(w) '_eps_' num2str(eps) '_kappa_' num2str(kappa) '_' type_of_sim '_lz_' num2str(lz)];

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
mCuSheet.Properties.Thickness = 100e-6;
mCuSheet.Properties.Kappa = 10e4;
materials{1} = mFR4;
materials{2} = mCuSheet;
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
elseif strcmp(type_of_sim,'LEFTRIGHT');
    rMaterial = mFR4;
    rEpsilon = rMaterial.Properties.Epsilon;
    rKappa = rMaterial.Properties.Kappa;
    sim_setup.PP.rEpsilon = rMaterial.Properties.Epsilon;
    sim_setup.PP.rKappa   = rMaterial.Properties.Kappa;
    sim_setup.Geometry.rMaterial = rMaterial;
    lMaterial = mFR4;
    lEpsilon = lMaterial.Properties.Epsilon;
    lKappa = lMaterial.Properties.Kappa;
    sim_setup.PP.lEpsilon = lMaterial.Properties.Epsilon;
    sim_setup.PP.lKappa   = lMaterial.Properties.Kappa;
    sim_setup.Geometry.lMaterial = lMaterial;
end;

fc = (sim_setup.FDTD.fstart+sim_setup.FDTD.fstop)/2;


% End of material definition
% Define the objects which are made of the defined materials
oFR4Slab.Name = 'FR4Background';
oFR4Slab.MName = 'FR4';
oFR4Slab.Type = 'Box';
oFR4Slab.Thickness = lz;
oFR4Slab.Prio = 2;
oFR4Slab.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4Slab.Bstop = [+UCDim/2, +UCDim/2, oFR4Slab.Thickness];

oRect1.Name = 'CopperRect';
oRect1.MName = 'CuSheet';
oRect1.Type = 'Polygon';
oRect1.Thickness = 0;
oRect1.Prio = 4;
oRect1.Transform = {'Translate', [-UCDim/4,-UCDim/4,0]};
NPoints = 5;
#Ri = L/2;
#Ra = UCDim/2;
#theta = [0,pi/4,3*pi/4,pi];
#Points(1,:) = [Ri, Ra, Ra,-Ra,-Ra,-Ri,-Ri,Ri,Ri];
#Points(2,:) = [0,0,Ra,Ra,0,0,Ri,Ri,0];
Points(1,:) = [-edgeL/2,edgeL/2,edgeL/2,-edgeL/2];
Points(2,:) = [-edgeL/2,-edgeL/2,edgeL/2,edgeL/2];
oRect1.Points = Points;

oEdge1.Name = 'CopperRing';
oEdge1.MName = 'CuSheet';
oEdge1.Type = 'Polygon';
oEdge1.Thickness = 0;
oEdge1.Prio = 4;
oEdge1.Points = [[L/2;L/2],[L/2-w;L/2],[L/2-w;-L/2],[L/2;-L/2]];

oRectRingElements = {oEdge1,oEdge1,oEdge1,oEdge1};
for i = 0:3;
    alpha = i*pi/2;
    oRectRingElements{i+1}.Transform = {'Rotate_Z', alpha, 'Translate', [UCDim/4,UCDim/4,0]};
end;

layer1.Name = 'FSS';
layer1.Thickness = 0;
layer1.objects{1} = oRect1;
layer1.objects = horzcat(layer1.objects,oRectRingElements);
layer2.Name = 'FR4';
layer2.Thickness = lz;
layer2.objects{1} = oFR4Slab;


sim_setup.used_layers = {layer1};
if strcmp(type_of_sim, 'EXACT');
    sim_setup.used_layers = {layer2,layer1};
end;
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);
end;
