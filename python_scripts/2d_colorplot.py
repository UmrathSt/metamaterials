import numpy as np
from matplotlib import pyplot as plt
from mpl_toolkits.axes_grid1 import axes_size, make_axes_locatable
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--infile", dest="infile", type=str)
parser.add_argument("--Xmin", dest="Xmin", type=float)
parser.add_argument("--Xmax", dest="Xmax", type=float)
parser.add_argument("--Ymin", dest="Ymin", type=float)
parser.add_argument("--Ymax", dest="Ymax", type=float)
args = parser.parse_args()

d = np.loadtxt(args.infile, delimiter=",")
[Xsh, Ysh] = d.shape

x = np.linspace(args.Xmin, args.Xmax, Xsh)
y = np.linspace(args.Ymin, args.Ymax, Ysh)
[X, Y] = np.meshgrid(y, x)
Z = 10*np.log10(d)

fig, ax = plt.subplots(figsize=(10,10))

cax = ax.pcolor(X, Y, Z, cmap="gray", alpha=0.5, vmin=-25, vmax=0)
contours = plt.contour(X, Y, Z,[-10,-3], colors="white")
plt.clabel(contours,inline=True,fontsize=12, manual=[(10,0.1),(20,1),(20,0.5),(25,0.7)],
            fmt="%.1f", inline_spacing=15)
ax.set_aspect(8)
ax.set_xlabel("f [GHz]")
cbar = fig.colorbar(cax, ticks=[-25,-10,-6,-3,0],fraction=0.03,pad=0.1)
plt.show()

