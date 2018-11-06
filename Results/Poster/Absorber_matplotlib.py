# -*- coding: utf-8 -*-
from matplotlib import pyplot as plt
import numpy as np
from matplotlib import rcParams
#from matplotlib import rc
#rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
#rc('text',usetex=True)

dataA = np.loadtxt("Reflection_coefficient_Poster.csv", delimiter = ",")
#dataR = np.loadtxt("S11__w1_1.5_w2_0.5_eps_4.2_kappa_0.05_EXACT_lz_2", delimiter = ",")
#dataS = np.loadtxt("S11__w1_1.5_w2_0.5_eps_4.2_kappa_0.05_EXACT_lz_2_DoubleSlots", delimiter = ",")
#f = dataR[:,0]/1e9
fA = dataA[:,0]
gratio = 1.618
fmax = 8 

fig = plt.figure(figsize=(3*gratio,4))
axL = fig.add_subplot(111)

axL.plot(fA, dataA[:,1]**2, "k-",linewidth=2,label="Reflexion")
axL.plot(fA, np.zeros(len(fA)),"b-", linewidth=2,label="Transmission")
axL.set_xlim([1,7])
axL.set_ylim([-0.01,1])
axL.set_ylabel("Reflexion",fontsize=16)
axL.set_xlabel("f [GHz]", fontsize=16)
axL.set_yticks([0,0.2,0.4,0.6,0.8,1],minor=False)
axL.set_yticks([0.1,0.3,0.5,0.7,0.9],minor=True)
axR = axL.twinx()
axR.set_ylabel("Transmission",fontsize=16,rotation=-90,labelpad=20,
        color="b")
#axR.set_yticks([])
#axR.set_ylabel("Transmission",fontsize=14,rotation=-90,ha="center")
axR.tick_params(axis='both',which='major',labelsize=12)
axL.tick_params(axis='both',which='major',labelsize=12)
axL.set_title("Ringe mit Kupferrückseite", fontsize=16)
plt.tight_layout()
plt.show()
fig.savefig("Absorber_matplotlib.png", format='png', dpi=200)
