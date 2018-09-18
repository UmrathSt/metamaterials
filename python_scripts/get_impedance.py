# get the impedance of a thin sheet from transmission and reflection coefficietns
import numpy as np
from matplotlib import pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--filename", dest="filename", type=str)
parser.add_argument("--Zr", dest="Zr", type=str)
parser.add_argument("--Zl", dest="Zl", type=str)
parser.add_argument("--lz", dest="lz", type=str)
parser.add_argument("--logscale", dest="logscale", type=str)
args = parser.parse_args()


filename = args.filename
d = np.loadtxt(filename, delimiter=",")
lz = float(args.lz)
Zr, Zl = complex(args.Zr), complex(args.Zl)
R = d[:,1]+1j*d[:,2] 
T = d[:,3]+1j*d[:,4]
f = d[:,0]
w = 2*np.pi*f
X = 1/(2*T*(1-R**2+T**2))
phase = X+1j*np.sqrt(1-X**2)
Zmeta = 376*np.sqrt(((1+R)**2-T**2)/((1-R)**2-T**2))
Zmeta *= np.sign(np.real(Zmeta))
lphase = np.log(phase)
n = 1/(w/3e8*lz)*(np.imag(lphase)-1j*np.real(lphase))
phase = X+np.sign(np.imag(n))*1j*np.sqrt(1-X**2)

lphase = np.log(phase)
n = 1/(w/3e8*lz)*(np.imag(lphase)-1j*np.real(lphase))
n = 1/(w/3e8*lz)*(np.imag(lphase)+0.5*(1-np.sign(np.real(n)))*2*np.pi-1j*np.real(lphase))
epsr = n/Zmeta
epsr *= np.sign(np.imag(epsr))
muer = Zmeta*n
muer *= np.sign(np.imag(muer))
plt.plot(f/1e9, np.real(epsr),"r-")
plt.plot(f/1e9, np.imag(epsr),"r--")
plt.plot(f/1e9, np.real(muer),"b-")
plt.plot(f/1e9, np.imag(muer),"b--")
plt.show()


print("args.logscale=", args.logscale)
if args.logscale == "True":
	plt.plot(np.log10(d[:,0]/1e9), np.log10(np.real(Zfss)),"r-", label="Re(Z)")
	plt.plot(np.log10(d[:,0]/1e9), np.log10(-np.imag(Zfss)),"b-", label="Im(Z)")
plt.plot((d[:,0]/1e9), (np.real(Zmeta)),"r-", label="Re(Z)")
plt.plot((d[:,0]/1e9), (np.imag(Zmeta)),"b-", label="Im(Z)")
plt.legend(loc="best").draw_frame(False)
plt.show()

plt.plot(d[:,0]/1e9, 1-np.abs(T)**2-np.abs(R)**2,"k-")
plt.show()
