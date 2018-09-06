# get the impedance of a thin sheet from transmission and reflection coefficietns
import numpy as np
from matplotlib import pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--filename", dest="filename", type=str)
parser.add_argument("--Zr", dest="Zr", type=str)
parser.add_argument("--Zl", dest="Zl", type=str)
parser.add_argument("--logscale", dest="logscale", type=str)
args = parser.parse_args()


filename = args.filename
d = np.loadtxt(filename, delimiter=",")

Zr, Zl = complex(args.Zr), complex(args.Zl)
R = d[:,1]+1j*d[:,2] 
T = d[:,3]+1j*d[:,4]

Zfss = Zl/T-1/T*np.sqrt(Zl**2-T**2*Zl*Zr) 
print("args.logscale=", args.logscale)
if args.logscale == "True":
	plt.plot(np.log10(d[:,0]/1e9), np.log10(np.real(Zfss)),"r-", label="Re(Z)")
	plt.plot(np.log10(d[:,0]/1e9), np.log10(-np.imag(Zfss)),"b-", label="Im(Z)")
plt.plot((d[:,0]/1e9), (np.real(Zfss)),"r-", label="Re(Z)")
plt.plot((d[:,0]/1e9), (np.imag(Zfss)),"b-", label="Im(Z)")
plt.legend(loc="best").draw_frame(False)
plt.show()

plt.plot(d[:,0]/1e9, 1-np.abs(T)**2-np.abs(R)**2,"k-")
plt.show()
