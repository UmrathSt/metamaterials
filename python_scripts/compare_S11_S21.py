import numpy as np
from matplotlib import pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--file1', dest='file1', type=str)
parser.add_argument('--file2', dest='file2', type=str)
parser.add_argument('--label1', dest='label1', type=str)
parser.add_argument('--label2', dest='label2', type=str)
parser.add_argument('--xlabel', dest='xlabel', type=str)
parser.add_argument('--ylabel', dest='ylabel', type=str)
args = parser.parse_args()

fig = plt.figure()
ax1 = fig.add_subplot(111)
ax2 = fig.add_subplot(221)

d1 = np.loadtxt(args.file1, delimiter=",")
d2 = np.loadtxt(args.file2, delimiter=",")

ax1.plot(d1[:,0]/1e9, abs(d1[:,1]+1j*d1[:,2]), label=args.label1+" S11", color="r")
ax1.plot(d2[:,0]/1e9, abs(d2[:,1]+1j*d2[:,2]), label=args.label2+" S11", color="b")
ax1.plot(d1[:,0]/1e9, abs(d1[:,3]+1j*d1[:,4]), label=args.label1+" S21", color="r--")
ax1.plot(d2[:,0]/1e9, abs(d2[:,3]+1j*d2[:,4]), label=args.label2+" S21", color="b--")

ax2.plot(d1[:,0]/1e9, np.angle(d1[:,1]+1j*d1[:,2]), label=args.label1+" S11", color="r")
ax2.plot(d2[:,0]/1e9, np.angle(d2[:,1]+1j*d2[:,2]), label=args.label2+" S11", color="b")
ax2.plot(d1[:,0]/1e9, np.angle(d1[:,3]+1j*d1[:,4]), label=args.label1+" S21", color="r--")
ax2.plot(d2[:,0]/1e9, np.angle(d2[:,3]+1j*d2[:,4]), label=args.label2+" S21", color="b--")

ax1.set_xlabel("f [GHz")
ax1.set_ylabel("|S11|, |S21|")
ax2.set_xlabel("f [GHz")
ax2.set_ylabel("phase(S11), phase(S21)")
plt.show()
