import numpy as np
from scipy.optimize import leastsq
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--eps", dest="eps",type=float)
parser.add_argument("--D", dest="D",type=float)
parser.add_argument("--L", dest="L",type=float)
parser.add_argument("--C", dest="C",type=float)
parser.add_argument("--tand", dest="tand",type=float)
parser.add_argument("--fsteps", dest="fsteps",type=int)
parser.add_argument("--fmax", dest="fmax",type=float)
parser.add_argument("--fmin", dest="fmin",type=float)
args = parser.parse_args()
f = np.linspace(args.fmin, args.fmax, args.fsteps)

def fit_func(R, L=args.L, C=args.C, f=f, D=args.D, eps=args.eps, tand=args.tand):
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

def reflection_integral(R):
    """ Calculate the integral of the reflection coefficient
        over the given frequency interval
    """
    Zfit = fit_func(R)
    Rfit = (Zfit-376)/(Zfit+376)
    return np.trapz(np.abs(Rfit), f)/(f[-1]-f[0])

R = leastsq(reflection_integral, x0=[10])[0]
print("obtained LSQ resistance: ", R)

