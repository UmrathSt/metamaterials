import numpy as np
import sys
sys.path.append("/home/stefan_dlr/Arbeit/openEMS/metamaterials/python_scripts")
from filesystem_tools import parameter_extraction, fileList
from filesystem_tools import flist_parameter_extraction
from equ_cir_fitting import find_minima
from matplotlib import pyplot as plt

hdir = "."
pname = "L"
ptype = float
sep = "_"
flist = fileList(hdir, "","05")
flist.sort(key= lambda x: parameter_extraction(x, pname, ptype, sep))

lz = flist_parameter_extraction(flist, pname, ptype, sep)

results = []
for fname in flist:
    results.append(np.loadtxt(fname, delimiter=","))

minima = []
for data in results:
    minima.append(find_minima(np.abs(data[:,1]+1j*data[:,2]),data[:,0],0.4))

f = results[0][:,0]
for i, minimum in enumerate(minima):
    min_idx = minimum[:,1]
    plt.plot(np.ones(len(min_idx))*lz[i], f[min_idx]/1e9, "ko")
plt.show()
