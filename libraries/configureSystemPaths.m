function Paths = configureSystemPaths(Paths, node)
Paths.SimBasePath = '/media/stefan/Daten/openEMS/metamaterials/';
Paths.ResultBasePath = '/home/stefan_dlr/Arbeit/openEMS/metamaterials/';
fprintf("\n Running on node %s \n", node);
if strcmp(node, 'vlinux');
    Paths.SimBasePath = '/mnt/hgfs/E/openEMS/metamaterials/';
    Paths.ResultBasePath = '/home/stefan/Arbeit/openEMS/metamaterials/';
elseif strcmp(node, 'XPS');
    fprintf('XPS node!!!\n');
    Paths.SimBasePath = '/home/stefan/Arbeit/metamaterials/Daten/';
    Paths.ResultBasePath = '/home/stefan/Arbeit/metamaterials/';
end;
    
end