import numpy as np
from matplotlib import pyplot as plt

dTE = np.loadtxt("SParameters_TE_ThetaScan.csv", delimiter=",")
dTM = np.loadtxt("SParameters_TM_ThetaScan.csv", delimiter=",")

f = dTE[:,0]
theta = np.linspace(0,55,12)
S11TM = dTE[:,1:12]*np.exp(1j*dTE[:,12:23])
S11TE = dTM[:,1:12]*np.exp(1j*dTM[:,12:23])
ZTE = (1+S11TE)/(1-S11TE)
ZTM = (1+S11TM)/(1-S11TM)
fig = plt.figure()
axL = fig.add_subplot(121)
axR = fig.add_subplot(122)

idx = 2
theta2 = theta[idx]
axL.plot(f, ZTE[:,0].real, "r-", label=r"Re($Z(\theta=0^\circ)$)")
axL.plot(f, ZTE[:,idx].real, "r--", label=r"Re($Z(\theta=%i^\circ)$)" %theta2)
axR.plot(f, ZTM[:,0].real, "r-",label=r"Re($Z(\theta=0^\circ)$)")
axR.plot(f, ZTM[:,idx].real, "r--",label=r"Re($Z(\theta=%i^\circ)$)" %theta2)

axL.plot(f, ZTE[:,0].imag, "b-", label=r"Im($Z(\theta=0^\circ)$)")
axL.plot(f, ZTE[:,idx].imag, "b--", label=r"Im($Z(\theta=%i^\circ)$)" %theta2)
axR.plot(f, ZTM[:,0].imag, "b-",label="$0^\circ$")
axR.plot(f, ZTM[:,idx].imag, "b--",label="$%i^\circ$" %theta2)

axL.set_title("TE-Polarisation")
axR.set_title("TM-Polarisation")
for ax in [axL, axR]:
    ax.set_xlim([4,7])
    ax.set_ylim([-5,5])
axL.legend(loc="best").draw_frame(False)
plt.show()

