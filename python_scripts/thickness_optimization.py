import numpy as np
from matplotlib import pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--L", dest="L", type=str)
parser.add_argument("--lzmin", dest="lzmin", type=str)
parser.add_argument("--lzmax", dest="lzmax", type=str)
parser.add_argument("--eps", dest="eps", type=str)
parser.add_argument("--kappa", dest="kappa", type=str)
args = parser.parse_args()


basepath = "/home/stefan/Arbeit/metamaterials/Results/SParameters/Stacked_RectCuAbsorber/"
basepath = "/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/Stacked_RectCuAbsorber/"
basepath = "/home/stefan_dlr/Arbeit/openEMS/metamaterials/Results/SParameters/Stacked_RectCuAbsorber/"
basepath = "/home/stefan_dlr/Arbeit/openEMS/metamaterials/Results/SParameters/XBandAbsorber/"
basepath = "/home/stefan/Arbeit/openEMS/metamaterials/Results/SParameters/XBandAbsorber/"

L = args.L
eps = args.eps
kappa = args.kappa
lzmax = float(args.lzmax)
lzmin = float(args.lzmin)

#dL = np.loadtxt(basepath+"S11_UCDim_14.25_R1_30_R2_300_LEFT_140_40_mitR_False", delimiter=",")
#dR = np.loadtxt(basepath+"S11_UCDim_14.25_R1_30_R2_300_RIGHT_140_40_mitR_False", delimiter=",")
dL = np.loadtxt(basepath+"S11_UCDim_14.25_R1_30_R2_300_LEFT_170_40_mitR_False", delimiter=",")
dR = np.loadtxt(basepath+"S11_UCDim_14.25_R1_30_R2_300_RIGHT_170_40_mitR_False", delimiter=",")

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

LZ = np.linspace(lzmin,lzmax,100)[np.newaxis,:]
phase = np.exp(-2*factor*LZ);
multiple_reflections = - T*Ts*phase/(1+Rs*phase)
S11 = R + multiple_reflections 
Z = np.abs(S11)**2

[X, Y] = np.meshgrid(LZ.flatten(), f.flatten())
fig, ax = plt.subplots(figsize=(10,10))
cax = ax.pcolor(X*1e3, Y/1e9, Z, cmap="RdGy", alpha=0.75, vmin=0, vmax=1)
cbar = plt.colorbar(cax,label="Reflection")
ax.tick_params('both',labelsize=14)
contours = plt.contour(X*1e3, Y/1e9, Z,[0.1,0.5], colors="black")
plt.clabel(contours,inline=True,fontsize=12, manual=[(2,5),(2,7.5),(4,7),(4,11)],
             fmt="%.1f", inline_spacing=15)


plt.xlabel("lz [mm]",fontsize=14)
plt.ylabel("f [GHz]")
plt.title("Cu patch edge length L=%s mm, $\epsilon=$ %s + i%s/2$\pi f \epsilon_0$" %(L,eps,kappa))

plt.savefig("XBandAbsorber_withoutR.pdf", format="pdf")
to_write = np.zeros((len(f), 5))
to_write[:,0] = f
to_write[:,1] = np.real(R[:,0])
to_write[:,2] = np.imag(R[:,0])
to_write[:,3] = np.real(multiple_reflections[:,59])
to_write[:,4] = np.imag(multiple_reflections[:,59])
comment = 'XBand absorber with fr4 thickness of %.2f mm thickness \n' %(LZ[0,59]*1000)
comment += 'freqeuncy, Re(R), Im(R), Re(MultipoleRef), Im(MultipleRef)'
np.savetxt("XBand_Reflections_Phase_withoutR.txt", to_write, delimiter=",", header=comment)
#plt.show()
