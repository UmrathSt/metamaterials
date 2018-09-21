import numpy as np
from matplotlib import pyplot as plt
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("--fname", dest="fname", type=str)
args = parser.parse_args()
d = np.loadtxt(args.fname, delimiter=",")

R, T = d[:,1]+1j*d[:,2], d[:,3]+1j*d[:,4]
sigmaE = (1-R-T)/(1+R+T)
sigmaM = (1+R-T)/(1-R+T)
plt.plot(d[:,0]/1e9,np.real(sigmaE),"r-",label="Re$\sigma_E$")
plt.plot(d[:,0]/1e9,np.imag(sigmaE),"r--",label="Im$\sigma_E$")
plt.plot(d[:,0]/1e9,np.real(sigmaM),"b-",label="Re$\sigma_M$")
plt.plot(d[:,0]/1e9,np.imag(sigmaM),"b--",label="Im$\sigma_M$")
plt.legend(loc="best").draw_frame(False)
plt.show()
