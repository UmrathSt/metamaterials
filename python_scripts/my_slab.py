import numpy as np
from matplotlib import pyplot as plt
from slab_scattering import SlabStructure as S
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("--N", dest="N", type=int)
parser.add_argument("--kappaMin", dest="kappaMin", type=float)
parser.add_argument("--kappaMax", dest="kappaMax", type=float)
parser.add_argument("--alpha", dest="alpha", type=float)
parser.add_argument("--Lges", dest="Lges", type=float)
arguments = parser.parse_args()

fmin, fmax = 1, 1000
f = np.linspace(fmin, fmax,500)*1e9
Nf = len(f)
Z0 = np.ones(Nf)*376.73
Lges = arguments.Lges
kappaMin = arguments.kappaMin 
kappaMax = arguments.kappaMax 
N = arguments.N 
decay =  arguments.alpha
kappas = lambda i: kappaMin - kappaMax*(1-1/(
                    1+np.exp(-decay*(i)**2))-0.5)/(
                    1/(1+np.exp(-decay))-0.5)
kappas = lambda i: kappaMin+kappaMax*(1+np.sin(i/10))
eps = np.zeros((2+N, Nf), dtype=np.complex128)
Zlist = np.zeros((2+N, Nf), dtype=np.complex128)
eps[0,:] = 1
for i in range(1,N+1):
    eps[i,:] = 1 + 1j*kappas(i)/(2*np.pi*f*8.85e-12)
eps[-1,:] = 56e6 
for i in range(0,N+2):
    Zlist[i,:] = Z0/np.sqrt(eps[i,:])
l = Lges/N*np.ones(N)[:,np.newaxis]
k = np.sqrt(eps)*2*np.pi*f/3e8
slabstack1 = S(Zlist, l, k)
R = slabstack1.build_gamma()
T = slabstack1.build_tau()
l = np.array([Lges])[:,np.newaxis]
eps = eps[[0,-2,-1],:]
k = np.sqrt(eps)*2*np.pi*f/3e8
Zlist2 = Z0/np.sqrt(eps)
slabstack2 = S(Zlist2,l,k)
R2 = slabstack2.build_gamma()
T2 = slabstack2.build_tau()

plt.semilogx(f, 20*np.log10(np.abs(R2)),"r-", label="single slab")
plt.semilogx(f, 20*np.log10(np.abs(R)),"b-", label="grading")
plt.legend(loc="best").draw_frame(False)
plt.show()

plt.plot(np.arange(N), kappas(np.arange(N)))
plt.show()
