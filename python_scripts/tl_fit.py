import numpy as np
from scipy.optimize import leastsq
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--filename", dest="filename",type=str)
parser.add_argument("--eps", dest="eps",type=float)
parser.add_argument("--D", dest="D",type=float)
parser.add_argument("--R", dest="R",type=float)
parser.add_argument("--L", dest="L",type=float)
parser.add_argument("--C", dest="C",type=float)
parser.add_argument("--tand", dest="tand",type=float)
parser.add_argument("--MaxIDX", dest="MaxIDX", type=int, default=-1)

args = parser.parse_args()

def fit_func(R, L, C, f, D, eps, tand):
    """ A Simple RLC series circuit in
        parallel to the analytically known
        impedance of a grounded dielectric
        slab of thickness D
    """
    w = 2*np.pi*f
    epsilon = eps*(1-tand*1j)
    Zd = 376j/np.sqrt(epsilon)*np.tan(w/3e8*np.sqrt(epsilon)*D)
    Zfss = R +1j*w*L + 1/(1j*w*C)
    Ztml = Zd
    Zges = np.conjugate((1/Zfss+1/Ztml)**(-1))
    Rges = (Zges-376)/(Zges+376)
    return Zges
def residuals(coeffs, S11num, f, D, eps, tand):
    R, L, C = coeffs
    Zges = fit_func(R, L, C, f, D, eps, tand)
    Rges = (Zges-376)/(376+Zges)
    val = np.abs(Rges.real-S11num.real)+np.abs(Rges.imag-S11num.imag)
    return val

x0 = [args.R, args.L, args.C]
data = np.loadtxt(args.filename, delimiter=",")
J = args.MaxIDX
f, S11 = data[0:J,0], data[0:J,1]+1j*data[0:J,2]
coeffs = leastsq(residuals, x0=x0, args=(S11, f, args.D, args.eps, args.tand))[0]
print(coeffs)
