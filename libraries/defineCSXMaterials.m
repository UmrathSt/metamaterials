function [CSX, matstring] = defineCSXMaterials(CSX, materials)
% add materials given in the structure materials to the CSX structure and
% ignore materials which already exist
% Example:
% substrate.Name = 'FR4';
% substrate.Type = 'Material';
% substarte.Properties.Epsilon = 4.6;
% substrate.Properties.Kappa = 2*pi*10e9*EPS0*0.1;
% materials{1} = substrate;
% [CSX, matstring] = defineCSXMaterials(CSX, materials);
% matstring will contain information on the added materials and is
% suitable for prepending it to result files
matstring = '# The following materials are used: \n';
for i = 1:length(materials);
    mat = materials{i};
    mName = mat.Name;
    mtype = mat.Type;
    % check if mat is a regular Material or a Conducting Sheet
    if ~(strcmp(mtype, 'Material') | strcmp(mtype, 'ConductingSheet'));
        Error("Possible types of material are mat.Type = \'Material\'  or mat.Type = \'ConductingSheet\'");
    end;
    % raise an error, if its neither a Material nor a ConductingSheet
    material_exists = 0;
    try;
        material_exists = CheckMaterialNameExistent(CSX.Properties.Material, mName);
        catch lasterror;
    end;
   try;
        material_exists = CheckMaterialNameExistent(CSX.Properties.ConductingSheet, mName);
        catch lasterror;
    end;
    if strcmp(mtype, 'Material') && ~material_exists;
        if strcmp(mtype, 'Material'); 
            % Material does not yet exist
            CSX = AddMaterial(CSX, mName);
            matstring = horzcat(matstring, ['# Material named ' mName ' with properties: ']);
            for [val, key] = mat.Properties;
                matstring = horzcat(matstring, [key ' = '  num2str(val) ', ']);
                CSX = SetMaterialProperty(CSX, mat.Name, key, val);
            end;
            matstring = horzcat(matstring, '\n');
        end;
        
    elseif strcmp(mtype, 'ConductingSheet') && ~ material_exists;
        % ConductingSheet does not yet exist
        matstring = horzcat(matstring, ['# ConductingSheet named ' mName ' with properties: ']);
        sheetThickness = mat.Properties.Thickness;
        sheetKappa = mat.Properties.Kappa;
        matstring = horzcat(matstring, ['Thickness = ' num2str(sheetThickness) ', Kappa = ' num2str(sheetKappa) '\n']);
        CSX = AddConductingSheet(CSX, mName, sheetKappa, sheetThickness);
    end;
end
end
        
