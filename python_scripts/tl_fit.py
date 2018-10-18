import numpy as np
from scipy.optimize import leastsq
from matplotlib import pyplot as plt
import argparse
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--filename", dest="filename",type=str)
    parser.add_argument("--eps", dest="eps",type=float)
    parser.add_argument("--D", dest="D",type=float)
    parser.add_argument("--R", dest="R",type=float)
    parser.add_argument("--L", dest="L",type=float)
    parser.add_argument("--C", dest="C",type=float)
    parser.add_argument("--tand", dest="tand",type=float)
    parser.add_argument("--fmin", dest="fmin", type=float)
    parser.add_argument("--fmax", dest="fmax", type=float)
    
    args = parser.parse_args()

def find_minima(R, f, bound,widths=[50]):
    """ Find all indices K for which the values in R are less than an
        upper bound and return 3xN numpy array containing [I, K, J]
        with K beeing the index where the R[K] = min(R[I:J])
        Takes:
        - R (np.ndarray): absolute value of reflection coefficient
        - f (np.ndarray) with shape of R: frequency
        - bound (float): 
        - widths (list of floats): wavelet used for smoothing noise
        Returns:
        - Nx3 np.ndarray
    """
    indices = signal.find_peaks_cwt(1/aR, widths)
    w = np.where(aR[indices] < 0.3)
    IDX_cand = indices[w]
    f_candidates = f[IDX_cand]
    interval_list = []
    I = 0
    for idx, i in enumerate(IDX_cand):
        Minimum = i
        try:
            imax = IDX_cand[idx+1]
        except IndexError:
            imax = -1
        J = (Minimum+imax)//2
        interval_list.append([I,Minimum,J])
        I = J
    K = IDX_cand[-1]
    J = -1
    interval_list.append([I,K,J])
    return interval_list

def fit_func(coeffs, f, D, eps, tand):
    """ A Simple RLC series circuit in
        parallel to the analytically known
        impedance of a grounded dielectric
        slab of thickness D
    """
    w = 2*np.pi*f
    R, L, C = coeffs
    epsilon = eps*(1+tand*1j)
    Zd = -376j/np.sqrt(epsilon)*np.tan(w/3e8*np.sqrt(epsilon)*D)
    Zfss = R - 1j*w*L + 1j/(w*C)
    Ztml = Zd
    Zges = (1/Zfss+1/Ztml)**(-1)
    Rges = (Zges-376)/(Zges+376)
    return Zges

def Rresiduals(coeffs, S11num, f, D, eps, tand):
    Zges = fit_func(coeffs, f, D, eps, tand)
    Rges = (Zges-376)/(376+Zges)
    S11num = S11num
    val = np.abs(Rges.real-S11num.real)+np.abs(Rges.imag-S11num.imag)
    return val

def Zresiduals(coeffs, S11num, f, D, eps, tand):
    Zges = fit_func(coeffs, f, D, eps, tand)
    Znum = 376*(1+S11num)/(1-S11num)
    val = np.abs(Zges.real-Znum.real)+np.abs(Zges.imag-Znum.imag)
    return val

if __name__ == "__main__":
    x0 = [args.R, args.L, args.C]
    data = np.loadtxt(args.filename, delimiter=",")
    fmin, fmax = args.fmin, args.fmax
    f = data[:,0]
    I = (np.abs(f-fmin)).argmin()
    J = (np.abs(f-fmax)).argmin()
    f, S11 = data[I:J,0], data[I:J,1]+1j*data[I:J,2]
    coeffs = leastsq(Rresiduals, x0=x0, args=(S11, f, args.D, args.eps, args.tand))[0]
    print(coeffs)
    Zfit = fit_func(coeffs, f, args.D, args.eps, args.tand)
    Rfit = (Zfit-376.7)/(Zfit+376.7)
    Znum = 376*(1+S11)/(1-S11)
    plt.plot(f/1e9, Rfit.real, "r-", label="Re(Rfit)")
    plt.plot(f/1e9, Rfit.imag, "b-", label="Im(Rfit)")
    plt.plot(f/1e9, S11.real, "m--", label="Re(Rnum)")
    plt.plot(f/1e9, S11.imag, "c--", label="Im(Rnum)")
    plt.plot(f/1e9, np.abs(S11), "k-", label="Abs(Rnum")
    plt.plot(f/1e9, np.abs(Rfit), "k--", label="Abs(Rfit")
    plt.legend(loc="best").draw_frame(False)
    plt.show()
    plt.plot(f/1e9, Zfit.real, "r-", label="Re(Zfit)")
    plt.plot(f/1e9, Zfit.imag, "b-", label="Im(Zfit)")
    plt.plot(f/1e9, Znum.real, "m--", label="Re(Znum)")
    plt.plot(f/1e9, Znum.imag, "c--", label="Im(Znum)")
    plt.legend(loc="best").draw_frame(False)
    plt.show()
