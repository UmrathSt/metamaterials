% Setup a dielectric FR4 slab simulation
function SetupDoubleRings(type_of_sim, UCDim, lz, R, w, dTheta, Theta0, eps, kappa,ZMESHRES=40,MESHRES=140);
addpath('../../libraries');
physical_constants;
node = uname.nodename();
% setup the system paths
Paths.SimPath = ['DoubleRings/UCDim_' num2str(UCDim)];
Paths.SimCSX = 'DoubleRings_geometry.xml';
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
sim_setup.FDTD.EndCriteria = 5e-5;
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
SParameters.ResultFilename = ['_R_' num2str(R) '_w_' num2str(w) '_eps_' num2str(eps) '_kappa_' num2str(kappa) '_' type_of_sim '_lz_' num2str(lz)];
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
mCuSheet.Name = 'CuSheet';
mCuSheet.Type = 'ConductingSheet';
mCuSheet.Properties.Thickness = 35e-6;
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

oFSS1.Name = 'FSS';
oFSS1.MName = 'CuSheet';
oFSS1.Type = 'Polygon';
oFSS1.Thickness = 0.;
oFSS1.Center = [0,0];
oFSS1.Prio = 4;
oFR4.Name = 'FR4Substrate';
oFR4.MName = 'FR4';
oFR4.Type = 'Box';
oFR4.Thickness = lz;
oFR4.Bstart = [-UCDim/2, -UCDim/2, 0];
oFR4.Bstop =  [UCDim/2, UCDim/2, oFR4.Thickness];
oFR4.Prio = 1;

NPoints = 50;

Ra = R;
Ri = R-w;
theta = linspace(dTheta/2,2*pi-dTheta/2,NPoints);
Points(1,:) = [Ri*cos(theta(1)), Ra.*cos(theta), Ri.*cos(theta)];
Points(2,:) = [Ri*sin(theta(1)), Ra.*sin(theta), -Ri.*sin(theta)];
oFSS1.Points = Points;
oFSS1.Transform = {'Rotate_Z', Theta0};
layer1.Name = 'FSS';
layer1.Thickness = 0;
layer1.objects{1} = oFSS1;
layer2.Name = 'Substrate';
layer2.Thickness = oFR4.Thickness;
layer2.objects{1} = oFR4;

sim_setup.used_layers = {layer1};
if strcmp(type_of_sim, 'EXACT');
    sim_setup.used_layers = {layer2,layer1};
end;
if lz == 0;
    sim_setup.used_layers = {layer1};
end;

sim_setup.used_materials = materials;
retval = setup_simulation(sim_setup);
end;