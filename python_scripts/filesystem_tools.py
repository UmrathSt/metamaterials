import os
import re

def fileList(source, beginswith, endswith):
    """ Retrieve files residing in a certain folder which 
        have certain pre-/suffixes
        Takes:
            - source (string): the root directory for treeing
            - beginswith (string): a string desired files begin with
            - endswith (string): a string desired files end with
        Returns:
            a list of all full paths to the found files
    """
    assert type(beginswith) == str and type(endswith) == str
    matches = []
    for root, dirnames, filenames in os.walk(source):
        for filename in filenames:
            if filename.endswith((endswith)) and filename.startswith((beginswith)):
                matches.append(os.path.join(root, filename))
    return sorted(matches)

def parameter_extraction(string, pname, ptype, separator):
    """ Extract the value for a given parameter specified
        by its pname from a given string
        Takes:
            - string (string): the string for which a parameter shall
                               be extracted
            - pname (string): the name of the parameter which is to
                              be extracted
            - ptype (type): the type of the extracted parameter type
            - separator (string): the separator which separates different 
                                  parameters
        Returns:
            a variable of type ptype containing the extracted parameter 
    """
    for s in [string, pname, separator]:
        assert type(s) == str
    assert(type(ptype) == type)
    split_s = string.split(pname+separator)[1] 
    result = split_s.split("/")[0]
    try:
        res = ptype(result)
        return res
    except ValueError:
        res = result.split("_")[0]
        return ptype(res)

def dir_parameter_extraction(directory, pname, ptype, separator):
    """ Do parameter extraction of function "parameter_extraction"
        for all files contained in a directory
        Takes:
            - directory (string): the directory to search
            - pname (string): the name of the parameter which is to
                              be extracted
            - ptype (type): the type of the extracted parameter type
            - separator (string): the separator which separates different 
                                  parameters
        Returns:
            a list containing variables of type ptype which represent the 
            extracted values for the parameter 
    """
    results = []
    files = fileList(directory,"","")
    for fname in files:
        results.append(parameter_extraction(fname, pname, ptype, separator))
    sres = set(results)
    ures = list(sres)
    ures.sort()
    return ures

if __name__ == "__main__":
    lz = dir_parameter_extraction("/home/stefan_dlr/Arbeit/openEMS/metamaterials/Results/SParameters/RectCuAbsorber/UCDim_7.2/"
                                    , "lz", float, "_")
    print(lz)
    L =  dir_parameter_extraction("/home/stefan_dlr/Arbeit/openEMS/metamaterials/Results/SParameters/RectCuAbsorber/UCDim_7.2/", "L", float,"_")
    print(L)
