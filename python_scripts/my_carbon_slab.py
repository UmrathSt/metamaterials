import numpy as np
from matplotlib import pyplot as plt
from slab_scattering import SlabStructure as S
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--L", dest="L", type=float)
parser.add_argument("--kappa", dest="kappa", type=float)
args = parser.parse_args()

fmin, fmax = 1, 40
f = np.linspace(fmin, fmax,500)*1e9
Nf = len(f)
Z0 = np.ones(Nf)*376.73
kappa1 = args.kappa
eps1 = 1
kappa2 = 0.05
eps2 = 4.6


eps = np.zeros((4, Nf), dtype=np.complex128)
Zlist = np.zeros((4, Nf), dtype=np.complex128)
eps[0,:] = 1
eps[1,:] = eps1 + 1j*kappa1/(2*np.pi*f*8.85e-12)
eps[2,:] = eps2 + 1j*kappa2/(2*np.pi*f*8.85e-12)
eps[3,:] = 56e6j 
for i in range(4):
    Zlist[i,:] = Z0/np.sqrt(eps[i,:])

l = np.array([25e-6,args.L])[:,np.newaxis]
k = np.sqrt(eps)*2*np.pi*f/3e8
slabstack1 = S(Zlist, l, k)
R = slabstack1.build_gamma()
T = slabstack1.build_tau()
fig = plt.figure()
ax1, ax2 = fig.add_subplot(211), fig.add_subplot(212)

ax1.plot(f/1e9, 20*np.log10(np.abs(T)),"r-", label="S21")
ax1.plot(f/1e9, 20*np.log10(np.abs(R)),"b-", label="S11")
ax2.plot(f/1e9, np.angle(T),"r-", label="S21")
ax2.plot(f/1e9, np.angle(R),"b-", label="S11")
ax1.legend(loc="best").draw_frame(False)
plt.show()

