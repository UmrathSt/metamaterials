function [CSX, geomstr, tbm] = AddLayers(CSX, layers, startz)
% Add object in layers and stack them starting at the coordinate [0, 0, startz]
% layers is supposed to be a cell array.
% Example:
% layer1{1}.Name = 'CuBackplane';
% layer1{1}.MName = 'FR4'; % has to be defined earlier via defineCSXMaterials.m
% layer1{1}.Type = 'Box';
% layer1{1}.Prio = 1;
% layer1{1}.Thickness = 1;
% layer1{1}.Bstart = [-10, -10, 0];
% layer1{1}.Bstop  = [10, 10, layer1{1}.Thickness];
tbm.x = [];
tbm.y = [];
tbm.z = [0];
tbm.TotalThickness = 0;
layerNo = length(layers);
geomstr = ['# Stacking a total of ' num2str(layerNo) ' layer(s).\n'];
for i = 1:layerNo; % loop over layers
    lay = layers{i};    
    objectNo = length(lay.objects);
    geomstr = horzcat(geomstr, ["# Found " num2str(objectNo) " object(s) in layer " ...
            num2str(i) " called \'" lay.Name "'\:\n"]);
    geomstr = horzcat(geomstr, ["# thickness of layer " num2str(i) " is "...
                     num2str(lay.Thickness) "\n" ]);
    tbm.z = [tbm.z, startz+lay.Thickness];
    tbm.TotalThickness = startz + lay.Thickness;
    trafostr = '';
    % set the minimum z-position of the current layer
    for j = 1:length(lay.objects) % loop over objects in each layer
        ob = lay.objects{j};
        Trafo = {}; % Perform no Transformation if it is not specified
        trafostr = '';
        try;
            Trafo = ob.Transform;
            trafostr = ['# Applied transformation(s) to object ' ob.Name ': '];
            for n = 1:length(Trafo);
                nTrafo = Trafo{n};
                type_of = typeinfo(nTrafo);
                info = 'None';
                if strcmp(type_of, 'sq_string');
                    info = nTrafo;
                elseif strcmp(type_of, 'scalar');
                    info = num2str(nTrafo);
                elseif strcmp(type_of, 'matrix');
                    info = mat2str(nTrafo);
                else error(['Expected transformation of type sq_string ', ...
                    'scalar or matrix but got: ' type_of]);
                end;
                trafostr = horzcat(trafostr, [info ', ']);
             end;
             trafostr = horzcat(trafostr, '\n');
        catch lasterror;
        end;
        if strcmp(ob.Type, 'Box');
            zshift = [0, 0, startz];
            start = ob.Bstart + zshift;
            stop  = ob.Bstop  + zshift;
            CSX = AddBox(CSX, ob.MName, ob.Prio, start, stop, ...
                            'Transform', Trafo);
            geomstr = horzcat(geomstr, ['# Box with start and stop coordinates ' ...
                                mat2str(start) ', ' mat2str(stop) ' made of material ' ob.MName '\n']);   
            geomstr = horzcat(geomstr, trafostr);
        elseif strcmp(ob.Type, 'Polygon');
            CSX = AddLinPoly(CSX, ob.MName, ob.Prio, 2, startz, ...
                             ob.Points, ob.Thickness, 'Transform', Trafo);
            geomstr = horzcat(geomstr, ['# Polygon with nodes (x, y) = ' ...
                        mat2str(ob.Points) ' made of material ' ob.MName ' at z = ' num2str(startz)  '..' ...
                                                        num2str(startz+ob.Thickness) '.\n']);  
            geomstr = horzcat(geomstr, trafostr);
        elseif strcmp(ob.Type, 'Ring');
            start = [ob.Center, startz];
            stop  = start + [0, 0, ob.Thickness];
            shell_width = ob.Ra-ob.Ri;
            rad = ob.Ra-shell_width/2;
            CSX = AddCylindricalShell(CSX, ob.MName, ob.Prio, start, stop, rad, shell_width, ...
                        'Transform', Trafo);
            geomstr = horzcat(geomstr, ['# Cylindrical shell width center (x,y) = ' mat2str(ob.Center) ...
                            ' made of material ' ob.MName ' at z = ' num2str(startz) '..' ...
                              num2str(startz+ob.Thickness) '. Outer radius Ra and inner radius Ri are '...
                              num2str(ob.Ra) ', ' num2str(ob.Ri) '.\n']);
        else error(["Unknown object type " ob.Type]);
        end;
    end;
    startz = startz + lay.Thickness;
end
