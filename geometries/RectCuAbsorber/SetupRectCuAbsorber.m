% Setup a dielectric FR4 slab simulation
function SetupRectCuAbsorber(UCDim, L, lz, kappa, eps, ZMESHRES=60,MESHRES=350);
addpath('../../libraries');
physical_constants;
node = uname.nodename();
% setup the system paths
Paths.SimPath = ['RectCuAbsorber/UCDim_' num2str(UCDim) '/lz_' num2str(lz)];
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
sim_setup.FDTD.EndCriteria = 1e-4;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.FDTD.PML = 'MUR';
sim_setup.Geometry.Show = 'False';
sim_setup.Geometry.grounded = 'True';
sim_setup.Geometry.MeshResolution = [MESHRES, MESHRES, ZMESHRES];
sim_setup.Geometry.Unit = 1e-3;

sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 10e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;

SParameters.ResultFilename = ['_L_' num2str(L) '_eps_' num2str(eps) '_kappa_' num2str(kappa)];

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
mCuSheet.Properties.Thickness = 35e-6;
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
oFR4Slab.Thickness = lz;
oFR4Slab.Prio = 2;
oFR4Slab.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4Slab.Bstop = [+UCDim/2, +UCDim/2, oFR4Slab.Thickness];

oRect.Name = 'CopperRect';
oRect.MName = 'CuSheet';
oRect.Type = 'Polygon';
oRect.Thickness = 0;
oRect.Prio = 4;
oRect.Points = [[-L/2;-L/2],[L/2;-L/2],[L/2;L/2],[-L/2;L/2]];


layer2.Name = 'FR4Substrate';
layer2.Thickness = oFR4Slab.Thickness;
layer2.objects{1} = oFR4Slab;
layer1.Name = 'FSS';
layer1.Thickness = 0;
layer1.objects{1} = oRect;

sim_setup.used_layers = {layer2,layer1};
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);

