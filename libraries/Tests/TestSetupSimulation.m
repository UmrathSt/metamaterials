% Test simulation setup
addpath('../');
sim_setup.FDTD.fstart = 1e9;
sim_setup.FDTD.fstop = 10e9;
sim_setup.FDTD.EndCriteria = 1e-6;
sim_setup.FDTD.Kinc = [0,0,-1];
sim_setup.FDTD.Polarization = [1,0,0];
sim_setup.Geometry.grounded = 'False';
sim_setup.PP = [];

retval = setup_simulation(sim_setup);