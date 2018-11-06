# -*- coding: utf-8 -*-
from matplotlib import pyplot as plt
import numpy as np
from matplotlib import rcParams
#from matplotlib import rc
#rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
#rc('text',usetex=True)

dataR = np.loadtxt("S11__w1_1.5_w2_0.5_eps_4.2_kappa_0.05_EXACT_lz_2", delimiter = ",")
dataS = np.loadtxt("S11__w1_1.5_w2_0.5_eps_4.2_kappa_0.05_EXACT_lz_2_DoubleSlots", delimiter = ",")
#fA = dataA[:,0]
gratio = 1.618
fR = dataR[:,0]/1e9
RR = np.abs(dataR[:,1]+1j*dataR[:,2])
RT = np.abs(dataR[:,3]+1j*dataR[:,4])
SR = np.abs(dataS[:,1]+1j*dataS[:,2])
ST = np.abs(dataS[:,3]+1j*dataS[:,4])
fS = dataS[:,0]/1e9
fmax = 8 
fig = plt.figure(figsize=(6*gratio,4))
# left half of the two figures
axleftRef = fig.add_subplot(121)
# right half of the two plots
axrightRef = fig.add_subplot(122)
axleftRef.plot(fR, RR**2, "k-",linewidth=2)
axleftRef.plot(fR, RT**2, "b-",linewidth=2)
axrightRef.plot(fR, SR**2, "k-",linewidth=2)
axrightRef.plot(fR, ST**2, "b-",linewidth=2)
axleftRef.set_title("Ringe ohne Kupferrückseite", fontsize=16)
axrightRef.set_title("Schlitze ohne Kuperrückseite", fontsize=16)
#axL.plot(fS, SR**2, "k--",linewidth=2,label="Schlitze")
#axR.plot(fS, ST**2, "b--",linewidth=2)
axleftRef.set_xlim([1,7])
axleftRef.set_ylabel("Reflexion", fontsize=16)
axleftRef.set_xlabel("f [GHz]", fontsize=16)
axleftRef.set_yticks([0,0.2,0.4,0.6,0.8,1],minor=False)
axleftRef.set_yticks([0.1,0.3,0.5,0.7,0.9],minor=True)
axleftRef.tick_params(axis='both',which='major',labelsize=12)
# right half
axrightRef.set_xlim([1,7])
axrightRef.set_ylabel("Reflexion", fontsize=16)
axrightRef.set_xlabel("f [GHz]", fontsize=16)
axrightRef.set_yticks([0,0.2,0.4,0.6,0.8,1],minor=False)
axrightRef.set_yticks([0.1,0.3,0.5,0.7,0.9],minor=True)
axrightRef.tick_params(axis='both',which='major',labelsize=12)
#axR = axL.twinx()
#axR.set_yticks([])
#axR.set_ylabel("Transmission",fontsize=14,rotation=-90,ha="center")
axleftTrans = axleftRef.twinx()
axrightTrans = axrightRef.twinx()
axrightTrans.set_ylabel("Transmission",fontsize=16,rotation=-90,labelpad=20,color="b")
# right half of the plots
axrightRef.set_xlabel("f [GHz]", fontsize=16)
axrightRef.set_ylim([0,1])
axrightRef.set_xlim([1,7])
axleftTrans.tick_params(axis='both',which='major',labelsize=12)
axrightTrans.tick_params(axis='both',which='major',labelsize=12)
axleftTrans.set_ylabel("Transmission",fontsize=16,rotation=-90,labelpad=20,color="b")
plt.tight_layout()
plt.show()
fig.savefig("Transmission_matplotlib.png", format='png', dpi=200)
