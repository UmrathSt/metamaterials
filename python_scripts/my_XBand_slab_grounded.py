import numpy as np
from matplotlib import pyplot as plt
from slab_scattering import SlabStructure as S
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--epsSheet", dest="epsSheet", type=float)
parser.add_argument("--epsSubst", dest="epsSubst", type=float,default=1)
parser.add_argument("--kappaSheet", dest="kappaSheet", type=float)
parser.add_argument("--kappaSubst", dest="kappaSubst", type=float,default=56e6)
parser.add_argument("--Lsheet", dest="Lsheet", type=float)
parser.add_argument("--Lsubst", dest="Lsubst", type=float)
parser.add_argument("--dumpfile", dest="dumpfile", type=str, default=False)
args = parser.parse_args()

fmin, fmax = 4, 20
f = np.linspace(fmin, fmax,500)*1e9
Nf = len(f)
Z0 = np.ones(Nf)*376.73
epsSubst, kappaSubst = args.epsSubst, args.kappaSubst # eps and kappa of the substrate
epsSheet, kappaSheet= args.epsSheet, args.kappaSheet
Lsheet = args.Lsheet
Lsubst = args.Lsubst

eps = np.zeros((4, Nf), dtype=np.complex128)
Zlist = np.zeros((4, Nf), dtype=np.complex128)
eps[0,:] = 1
eps[1,:] = epsSheet + 1j*kappaSheet/(2*np.pi+f*8.85e-12)
eps[2,:] = epsSubst + 1j*kappaSubst/(2*np.pi*f*8.85e-12)
eps[3,:] = 56e6j 
for i in range(np.shape(eps)[0]):
    Zlist[i,:] = Z0/np.sqrt(eps[i,:])

l = np.array([Lsheet, Lsubst])[:,np.newaxis]
k = np.sqrt(eps)*2*np.pi*f/3e8
slabstack1 = S(Zlist, l, k)
R = slabstack1.build_gamma()
T = slabstack1.build_tau()
fig = plt.figure()
ax1, ax2 = fig.add_subplot(211), fig.add_subplot(212)

ax1.plot(f/1e9, 20*np.log10(np.abs(T)),"r-", label="S21")
ax1.plot(f/1e9, 20*np.log10(np.abs(R)),"b-", label="S11")
ax2.plot(f/1e9, 180/np.pi*np.angle(T),"r-", label="S21")
ax2.plot(f/1e9, 180/np.pi*np.angle(R),"b-", label="S11")
ax1.set_ylabel("$20\log|S_{11}|^2$")
ax1.legend(loc="best").draw_frame(False)
if args.dumpfile:
    f, R, T = f[:,np.newaxis], R[:,np.newaxis], T[:,np.newaxis]
    result = np.concatenate((f,R.real,R.imag, T.real,T.imag),1)
    header = r"scattering from a 25 micron conducting sheet with kappa = %.2f on top of %.2e m copper backed FR4." %(args.kappaSheet, args.Lsheet)
    np.savetxt(args.dumpfile, result, delimiter=",", header=header)
plt.show()

