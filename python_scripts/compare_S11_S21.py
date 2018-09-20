import numpy as np
from matplotlib import pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--file1', dest='file1', type=str)
parser.add_argument('--file2', dest='file2', type=str)
parser.add_argument('--delim1', dest='delim1', type=str,default=',')
parser.add_argument('--delim2', dest='delim2', type=str,default=',')
parser.add_argument('--label1', dest='label1', type=str)
parser.add_argument('--label2', dest='label2', type=str)
args = parser.parse_args()

fig = plt.figure()
ax1 = fig.add_subplot(211)
ax2 = fig.add_subplot(212)

d1 = np.loadtxt(args.file1, delimiter=args.delim1)
d2 = np.loadtxt(args.file2, delimiter=args.delim2)

ax1.plot(d1[:,0]/1e9, 10*np.log10(abs(d1[:,1]+1j*d1[:,2])**2), "r-", label=args.label1+" S11")
ax1.plot(d2[:,0]/1e9, 10*np.log10(abs(d2[:,1]+1j*d2[:,2])**2), "r--", label=args.label2+" S11")
ax1.plot(d1[:,0]/1e9, 10*np.log10(abs(d1[:,3]+1j*d1[:,4])**2), "b-", label=args.label1+" S21")
ax1.plot(d2[:,0]/1e9, 10*np.log10(abs(d2[:,3]+1j*d2[:,4])**2), "b--", label=args.label2+" S21")

ax2.plot(d1[:,0]/1e9, -np.angle(d1[:,1]+1j*d1[:,2]), "r-", label=args.label1+" S11")
ax2.plot(d2[:,0]/1e9, np.angle(d2[:,1]+1j*d2[:,2]), "r--", label=args.label2+" S11")
ax2.plot(d1[:,0]/1e9, -np.angle(d1[:,3]+1j*d1[:,4]), "b-", label=args.label1+" S21")
ax2.plot(d2[:,0]/1e9, np.angle(d2[:,3]+1j*d2[:,4]), "b--", label=args.label2+" S21")

ax1.set_xlabel("f [GHz]")
ax1.set_ylabel("|S11|^2, |S21|^2")
ax2.set_xlabel("f [GHz]")
ax2.set_ylabel("phase(S11,S21)")
ax1.legend(loc="best").draw_frame(False)
plt.tight_layout()
plt.show()
