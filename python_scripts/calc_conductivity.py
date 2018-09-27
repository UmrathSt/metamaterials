import numpy as np
from matplotlib import pyplot as plt
import argparse
# calculate effective FSS conductivities according to 
# Tassin et al. Physica B 407, 4062-4065 (2012)
parser = argparse.ArgumentParser()
parser.add_argument('--filename', dest='filename', type=str)
args = parser.parse_args()
filename = args.filename


d = np.loadtxt(filename, delimiter=",")

f, R, T = d[:,0]/1e9, d[:,1]+1j*d[:,2], d[:,3]+1j*d[:,4]
Z0 = np.sqrt(4*np.pi*1e-7/8.85e-12)
Z0 = 1

sigmaE = (1-R-T)/(1+R+T)
sigmaM = (1+R-T)/(1-R+T)
fig, (ax1, ax2) = plt.subplots(2,1, sharex=True)
#ax1.set_title("conductivities of XBand absorber with $R_1=30$ $\Omega$ and $R_2=300$ $\Omega$.")
ax1.plot(f, sigmaE.real,"r-", label="Re $\sigma_E$")
ax1.plot(f, sigmaM.real,"b-", label="Re $\sigma_M$")
ax1.plot(f, sigmaE.imag,"r--", label="Im $\sigma_E$")
ax1.plot(f, sigmaM.imag,"b--", label="Im $\sigma_M$")
angle_deg = 180/np.pi
ax2.plot(f, angle_deg*np.angle(sigmaE),"r-")
ax2.plot(f, angle_deg*np.angle(sigmaM),"b-")
ax1.legend(loc="best").draw_frame(False)
ax1.set_ylabel(r"$|\sigma_E|,|\sigma_M|$")
ax2.set_ylabel(r"$\arg{\sigma_E},\arg{\sigma_M}$")
ax2.set_xlabel("frequency [GHz]")
fig.tight_layout()
plt.show()
