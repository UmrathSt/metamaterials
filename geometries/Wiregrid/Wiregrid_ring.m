function Wiregrid_ring(type_of_sim, UCDim, lz, N, w, L, eps, kappa, with_ring, ZMESHRES=40,MESHRES=140);
% Setup a wiregrid slab simulation
% intended for the calculation of transmission and reflection coefficients
% for varying Cu edge-length in order to minimize the reflection of a stacked structure
addpath('../../libraries');
physical_constants;
node = uname.nodename();
% setup the system paths
Paths.SimPath = 'WireGrid_ring';
Paths.SimCSX = 'WireGrid_geometry.xml';
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
sim_setup.FDTD.EndCriteria = 1e-6;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.FDTD.PML = 'MUR';
sim_setup.Geometry.Show = 'True';
sim_setup.Geometry.grounded = 'False';
if strcmp(type_of_sim,'LEFT') || strcmp(type_of_sim,'RIGHT') || strcmp(type_of_sim,'LEFTRIGHT');
    sim_setup.Geometry.grounded = 'False';
end;
sim_setup.Geometry.MeshResolution = [MESHRES,MESHRES,ZMESHRES];
sim_setup.Geometry.Unit = 1e-3;

sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 10e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;

SParameters.ResultFilename = ['UCDim_' num2str(UCDim) '_N_' num2str(N) '_w_' num2str(w) '_eps_' num2str(eps) '_kappa_' num2str(kappa) '_' type_of_sim '_lz_' num2str(lz) '_withRing_' with_ring];

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
mCuSheet.Properties.Thickness = 0;
mCuSheet.Properties.Kappa = 56e6;
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

oGridX.Name = 'CopperGrid';
oGridX.MName = 'CuSheet';
oGridX.Type = 'Polygon';
oGridX.Thickness = 0;
oGridX.Prio = 4;
dY = UCDim/N;
oGridX.Points = [[-UCDim/2;w/2],[UCDim/2;w/2],[UCDim/2;-w/2],[-UCDim/2;-w/2]];
oGridY = oGridX;
oGridY.Points(1,:) = oGridX.Points(2,:);
oGridY.Points(2,:) = oGridX.Points(1,:);

oRect.Name = 'RectTing';
oRect.MName = 'CuSheet';
oRect.Type = 'Polygon';
oRect.Thickness = 0;
oRect.Prio = 4; 
Lg = L/2;
Ls = L/2-w;
oRect.Points = [[Ls;Lg],[Lg;Lg],[Lg;-Ls],[Ls;-Ls]];
for i = 0:3;
    Rectangles{i+1} = oRect;
    Rectangles{i+1}.Transform = {'Rotate_Z', pi/2*i};
end;
for i = 0:N-1;
    Grid{2*i+1} = oGridX;
    Grid{2*i+2}   = oGridY;
    Grid{2*i+1}.Transform = {'Translate', [0,-UCDim/2+i*2.5,0]};
    Grid{2*i+2}.Transform =   {'Translate', [-UCDim/2+i*2.5,0,0]};
end;

layer1.Name = 'FSS';
layer1.Thickness = 0;
layer1.objects = Grid;
layer2.Name = 'FR4';
layer2.Thickness = lz;
layer2.objects{1} = oFR4Slab;
layer3.Name = 'Ring';
layer3.Thickness = 0;
layer3.objects = Rectangles;


sim_setup.used_layers = {layer3,layer2,layer2,layer1};
if strcmp(with_ring, 'False');
    sim_setup.used_layers = {layer2,layer2,layer1};
end;

sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);
end;
