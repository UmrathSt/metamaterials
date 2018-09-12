import numpy as np
from matplotlib import pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--L", dest="L", type=str)
parser.add_argument("--lz", dest="lz", type=str)
parser.add_argument("--Lz", dest="Lz", type=str)
parser.add_argument("--eps", dest="eps", type=str)
parser.add_argument("--kappa", dest="kappa", type=str)
parser.add_argument("--ref_file", dest="ref_file", type=str)
args = parser.parse_args()


basepath = "/home/stefan/Arbeit/metamaterials/Results/SParameters/Stacked_RectCuAbsorber/"
basepath = "/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/Stacked_RectCuAbsorber/"

L = args.L
eps = args.eps
kappa = args.kappa
lz = args.lz
Lz = args.Lz
dref = args.ref_file

dL = np.loadtxt(basepath+"S11_UCDim_4_L_%s_eps_%s_kappa_%s_"%(L,eps,kappa)+"LEFT"+"_lz_%s"%(lz), delimiter=",")
dR = np.loadtxt(basepath+"S11_UCDim_4_L_%s_eps_%s_kappa_%s_"%(L,eps,kappa)+"RIGHT"+"_lz_%s"%(lz), delimiter=",")
dref = np.loadtxt(dref, delimiter=",")

def calcPropagationConstant(w, eps, kappa):
    EPS0 = 8.85e-12
    c0 = 2.998e8
    MUE0 = 4*np.pi*1e-7
    alpha = w*np.sqrt(eps)/c0/np.sqrt(2)*np.sqrt(1+np.sqrt(1+(kappa/(w*eps*EPS0))**2))
    beta  = w*MUE0*kappa/(2*alpha)
    return alpha, beta


f = dL[:,0]
assert np.all(f==dR[:,0])
w = 2*np.pi*f
w = w[:,np.newaxis]
alpha, beta = calcPropagationConstant(w, float(eps), float(kappa))
R, T = dR[:,1]+1j*dR[:,2], dR[:,3]+1j*dR[:,4] # dataset with substrate on the right of the FSS
Rs, Ts = dL[:,1]+1j*dL[:,2], dL[:,3]+1j*dL[:,4] # dataset with substrate on the left of the FSS
factor = -1j*alpha+beta;
R, T, Rs, Ts = R[:,np.newaxis], T[:,np.newaxis], Rs[:,np.newaxis], Ts[:,np.newaxis]

LZ = np.array([float(Lz)])[np.newaxis,:]
phase = np.exp(-2*factor*LZ);
S11 = R - T*Ts*phase/(1+Rs*phase)
Z = np.abs(S11)**2
plt.plot(f/1e9, (Z[:,0]), label="Interference Theory")
plt.plot(dref[:,0]/1e9, abs(dref[:,1]+1j*dref[:,2])**2, label="full Wave")
plt.ylabel("$|S11|^2$",fontsize=14)
plt.xlabel("f [GHz]")
plt.legend(loc="best").draw_frame(False)
plt.title("Cu patch edge length L=%s mm, $lz_\mathrm{subs}=$ %s, $\epsilon=$ %s + i%s/2$\pi f \epsilon_0$" %(L,Lz,eps,kappa))

plt.show()
