import numpy as np
from scipy.optimize import leastsq
from matplotlib import pyplot as plt
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--filename", dest="filename",type=str)
parser.add_argument("--eps", dest="eps",type=float)
parser.add_argument("--D", dest="D",type=float)
parser.add_argument("--R1", dest="R1",type=float)
parser.add_argument("--L1", dest="L1",type=float)
parser.add_argument("--C1", dest="C1",type=float)
parser.add_argument("--R2", dest="R2",type=float)
parser.add_argument("--L2", dest="L2",type=float)
parser.add_argument("--C2", dest="C2",type=float)
parser.add_argument("--tand", dest="tand",type=float)
parser.add_argument("--MaxIDX", dest="MaxIDX", type=int, default=-1)
parser.add_argument("--MinIDX", dest="MinIDX", type=int, default=0)

args = parser.parse_args()

def fit_func(R1, L1, C1, R2, L2, C2, f, D, eps, tand):
    """ A two parallel RLC circuits coupled capacitively 
        parallel to the analytically known
        impedance of a grounded dielectric
        slab of thickness D
    """
    w = 2*np.pi*f
    epsilon = eps*(1-tand*1j)
    Zd = 376j/np.sqrt(epsilon)*np.tan(w/3e8*np.sqrt(epsilon)*D)
    Z1ts = R1 + 1j*w*L1 - 1j/(w*C1) 
    Z2ts = R2 + 1j*w*L2 - 1j/(w*C2) 
    Zges = np.conjugate((1/Zd+1/Z1ts+1/Z2ts)**(-1))
    Rges = (Zges-376)/(Zges+376)
    return Zges

def residuals(coeffs, S11num, f, D, eps, tand):
    R1, L1, C1, R2, L2, C2 = coeffs
    Zges = fit_func(R1, L1, C1, R2, L2, C2, f, D, eps, tand)
    Rges = (Zges-376)/(376+Zges)
    val = np.abs(Rges.real-S11num.real)+np.abs(Rges.imag-S11num.imag)
    return val

x0 = [args.R1, args.L1, args.C1, 
      args.R2, args.L2, args.C2] 
 #     args.RC, args.LC, args.CC]
data = np.loadtxt(args.filename, delimiter=",")
I, J = args.MinIDX, args.MaxIDX
f, S11 = data[I:J,0], data[I:J,1]+1j*data[I:J,2]
coeffs = leastsq(residuals, x0=x0, args=(S11, f, args.D, args.eps, args.tand))[0]
print("R1 = %.2e, L1 = %.2e, C1 = %.2e " %(coeffs[0],coeffs[1],coeffs[2]))
print("R2 = %.2e, L2 = %.2e, C2 = %.2e " %(coeffs[3],coeffs[4],coeffs[5]))

Zges = fit_func(*coeffs, f, args.D, args.eps, args.tand)
Rges = (Zges-376)/(Zges+376)
plt.plot(f/1e9, np.abs(Rges)**2, "r-", linewidth=2, label="Circuit")
plt.plot(f/1e9, np.abs(S11)**2, "b-", linewidth=2, label="openEMS")
plt.legend(loc="best").draw_frame(False)
plt.show()
