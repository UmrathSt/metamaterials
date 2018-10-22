import os
import re

def fileList(source, beginswith, endswith):
    """ Retrieve files residing in a given source folder which 
        have certain pre-/suffixes
        Takes:
            - source (string): the root directory for treeing
            - beginswith (string): a string holding the prefix of 
              the desired filenames
            - endswith (string): a string holding the postfix of
              the desired filenames
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
    split_s = string.split(pname+separator)
    print("the string I am trying to split is: \n", split_s)
    split_s = split_s[1] 
    result = split_s.split("/")[0]
    try:
        res = ptype(result)
        return res
    except ValueError:
        res = result.split("_")[0]
        return ptype(res)

def flist_parameter_extraction(flist, pname, ptype, separator):
    """ Do parameter extraction of function "parameter_extraction"
        for all files contained in a directory
        Takes:
            - flist (a list of strings): the filenames to search
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
    for fname in flist:
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
