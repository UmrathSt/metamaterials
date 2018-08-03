function retval = CheckMaterialNameExistent(CSXProperties, name)
% Check if in the cell-array CSXProperties an ATTRIBUTE.Name == name
% already exists. Return 0 if not and 1 if it does exist
retval = 0;
for i = 1:length(CSXProperties);
    ntemp = CSXProperties{i}.ATTRIBUTE.Name;
    if strcmp(ntemp, name);
        retval = 1;
        return
    end;
end;
end
    