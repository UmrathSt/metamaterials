import numpy as np
from matplotlib import pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--L", dest="L", type=str)
args = parser.parse_args()


basepath = "/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/Stacked_RectCuAbsorber/"

L = args.L

dL = np.loadtxt(basepath+"S11_UCDim_4_L_%s_eps_4.6_kappa_0.05_"%L+"LEFT", delimiter=",")
dR = np.loadtxt(basepath+"S11_UCDim_4_L_%s_eps_4.6_kappa_0.05_"%L+"RIGHT", delimiter=",")

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
alpha, beta = calcPropagationConstant(w, 4.6, 0.05)
R, T = dR[:,1]+1j*dR[:,2], dR[:,3]+1j*dR[:,4] # dataset with substrate on the right of the FSS
Rs, Ts = dL[:,1]+1j*dL[:,2], dL[:,3]+1j*dL[:,4] # dataset with substrate on the left of the FSS
factor = -1j*alpha+beta;
R, T, Rs, Ts = R[:,np.newaxis], T[:,np.newaxis], Rs[:,np.newaxis], Ts[:,np.newaxis]

LZ = np.linspace(1e-5,1e-2,100)[np.newaxis,:]
phase = np.exp(-2*factor*LZ);
S11 = R - T*Ts*phase/(1+Rs*phase)

[X, Y] = np.meshgrid(LZ.flatten(), f.flatten())
plt.pcolor(X*1e3, Y/1e9, np.abs(S11)**2, cmap="RdGy")
plt.xlabel("lz [mm]")
plt.ylabel("f [GHz]")
plt.title("Cu patch edge length L=%s mm" %L)
cbar = plt.colorbar(label="Reflection")

plt.savefig("CuPatch_L_%s" %L, format="pdf")
plt.show()
