% Test whether adding layers to a CSX structure
% works without errors

clear;
clc;
addpath('../');

CSX = InitCSX();

mCu.Name = 'Cu';
mCu.Type = 'Material';
mCu.Properties.Kappa = 56e6;
mFR4.Name = 'FR4';
mFR4.Type = 'Material';
mFR4.Properties.Kappa = 0.1;
mFR4.Properties.Epsilon = 4.6;
materials{1} = mCu;
materials{2} = mFR4;

[CSX, matstring] = defineCSXMaterials(CSX, materials);

oBackPlane.Name = 'CopperBackplane';
oBackPlane.MName = 'Cu';
oBackPlane.Type = 'Box';
oBackPlane.Thickness = 1;
oBackPlane.Bstart = [-10, -10, 0];
oBackPlane.Bstop =  [+10, +10, 0.05];
oBackPlane.Prio = 1;
oPoly.Name = 'CopperPolygon';
oPoly.MName = 'Cu';
oPoly.Type = 'Polygon';
oPoly.Thickness = 1;
oPoly.Points = [[0;1],[1;1],[1;0]];
oPoly.Prio = 1;
oFSSBackground.Name = 'FR4Background';
oFSSBackground.MName = 'FR4';
oFSSBackground.Type = 'Box';
oFSSBackground.Thickness = 1;
oFSSBackground.Prio = 1;
oFSSBackground.Bstart = [-10, -10, 0];
oFSSBackground.Bstop =  [+10, +10, 1];



layer1.Name = 'SolidCuLayer';
layer1.objects{1} = oBackPlane;
layer2.Name = 'FSSlayer';
layer2.objects{1} = oPoly;
layer2.objects{2} = oFSSBackground;
layers{1} = layer1;
layers{2} = layer2;

[CSX, geomstring, to_be_meshed] = AddLayers(CSX, layers, 0);
fprintf('If no errors are displayd, then ');
fprintf(["it seems that everything worked. \nCheck the \'CSX\' structure, \'geomstring\' ", ...
               "and \'to_be_meshed\' for unexpected results. \n"]);
fprintf('--- Output ---\n');
fprintf('The geometry you specified leads to the following string:\n');
fprintf(geomstring);
fprintf(matstring);





