% Test whether adding layers to a CSX structure
% works without errors

clear;
clc;

CSX = InitCSX();

copper.Name = 'Cu';
copper.Type = 'Material';
copper.Properties.Kappa = 56e6;
materials{1} = copper;

[CSX, matstr] = defineCSXMaterials(CSX, materials);

object.Name = 'CopperBackplane';
object.MName = 'Cu';
object.Type = 'Box';
object.Thickness = 1;
object.Bstart = [-10, -10, 0];
object.Bstop =  [+10, +10, 1];
object.Prio = 1;
layer1.Name = 'Solid Copper Background';
layer1.objects{1} = object;
layers{1} = layer1;

[CSX, geomstring, to_be_meshed] = AddLayers(CSX, layers, 0);





