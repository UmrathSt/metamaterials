% Setup a dielectric FR4 slab simulation
clc;
clear;
addpath('../../libraries');
physical_constants;
node = uname.nodename();
% setup the system paths
Paths.SimPath = 'DoubleRings';
Paths.SimCSX = 'DoubleRings_geometry.xml';
Paths = configureSystemPaths(Paths, node);
addpath([Paths.ResultBasePath 'libraries/']);
Paths.ResultPath = ['Results/SParameters/' Paths.SimPath];
sim_setup.Paths = Paths; 
%-----------------system path setup END---------------------------------------|
sim_setup.Paths = Paths;
sim_setup.FDTD.Write = 'True';
sim_setup.FDTD.numThreads = 6;
sim_setup.FDTD.Run = 'True';
sim_setup.FDTD.fstart = 3e9;
sim_setup.FDTD.fstop = 20e9;
sim_setup.FDTD.EndCriteria = 5e-5;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.FDTD.PML = 'MUR';
sim_setup.Geometry.Show = 'True';
sim_setup.Geometry.grounded = 'False';
sim_setup.Geometry.MeshResolution = [80, 80,40];
sim_setup.Geometry.Unit = 1e-3;
UCDim = 20;
sim_setup.Geometry.UCDim = [UCDim, UCDim]; % size of the unit-cell in the xy-plane
SParameters.df = 10e6;
SParameters.fstart = sim_setup.FDTD.fstart;
SParameters.fstop = sim_setup.FDTD.fstop;
SParameters.ResultFilename = 'tmp';
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
mCuSheet.Properties.Thickness = 18e-6;
mCuSheet.Properties.Kappa = 56e6;
materials{1} = mFR4;
materials{2} = mCuSheet;
rMaterial = mFR4;
rEpsilon = rMaterial.Properties.Epsilon;
rKappa = rMaterial.Properties.Kappa;
sim_setup.PP.rEpsilon = rMaterial.Properties.Epsilon;
sim_setup.PP.rKappa   = rMaterial.Properties.Kappa;
sim_setup.Geometry.rMaterial = rMaterial;
fc = (sim_setup.FDTD.fstart+sim_setup.FDTD.fstop)/2;
% End of material definition
% Define the objects which are made of the defined materials

oFSS1.Name = 'FSS';
oFSS1.MName = 'CuSheet';
oFSS1.Type = 'Polygon';
oFSS1.Thickness = 0.;
oFSS1.Center = [0,0];
oFSS1.Prio = 4;
NPoints = 101;
Ra = 9.8;
Ri = 8.3;
R = Ra;
sign = 1;
for i = 1:NPoints;
    if i>=51;
        i = i-1;
        R = Ri;
        sign = -1;
    end;
    Points(1,i) = R*cos(sign*2*pi/50*i);
    Points(2,i) = R*sin(sign*2*pi/50*i);
end;
oFSS1.Points = Points;




layer2.Name = 'FSS';
layer2.Thickness = 0;
layer2.objects{1} = oFSS1;


sim_setup.used_layers = {layer2};
sim_setup.used_materials = materials;

retval = setup_simulation(sim_setup);

