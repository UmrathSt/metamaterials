# -*- coding: utf-8 -*-
from matplotlib import pyplot as plt
import numpy as np
from matplotlib import rcParams
from matplotlib.patches import Rectangle

dataA = np.loadtxt("XbandAbsorber_15_150_Ohm_Messung.txt", delimiter = ",")
fA = dataA[:,0]
R = np.abs(dataA[:,1]+1j*dataA[:,2])
gratio = 1.618
fmax = 8 

fig = plt.figure(figsize=(3*gratio,4))
axL = fig.add_subplot(111)

axL.plot(fA, 20*np.log10(R), "k-",linewidth=2,label="Reflexion")
xmin, xmax = 6, 14
ymin, ymax = -25, 0
axL.set_xlim([xmin,xmax])
axL.set_ylim([ymin,ymax])
axL.set_ylabel("Reflexion [dB]",fontsize=16)
axL.set_xlabel("f [GHz]", fontsize=16)
axL.set_yticks([-20,-10,0],minor=False)
axL.set_yticks([-25,-15,-5],minor=True)
axL.set_xticks(np.arange(xmin,xmax+1,2),minor=False)
axL.set_xticks(np.arange(xmin,xmax,2)+1,minor=True)
LX, LY = 4.2, ymax-ymin
axL.add_patch(Rectangle((8.2,ymin),LX,LY,facecolor="grey", alpha=0.2))
axL.tick_params(axis='both',which='major',labelsize=12)
arrowL = 0.5
axL.arrow(8.2, -5, LX-arrowL, 0, fc='k', ec='k', head_width=0.5,
       shape="full", head_length=arrowL)
axL.arrow(12.4, -5, -(LX-arrowL), 0, fc='k', ec='k', head_width=0.5,
       shape="full", head_length=arrowL)
plt.text(9.5,-4.5,"X-Band", fontsize=14)
plt.tight_layout()
plt.show()
fig.savefig("XBand_Absorber_matplotlib.png", format='png', dpi=200)
