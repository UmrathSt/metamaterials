import numpy as np
from math import sqrt
from scipy.optimize import leastsq
from matplotlib import pyplot as plt
from scipy import signal
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
    parser.add_argument("--plot", dest="plot", type=bool,default=False)
    args = parser.parse_args()

Z0 = 273.73 # vacuum impedance

def find_minima(R, f, bound, widths=[50]):
    """ Find all indices i for which R[i], corresponding to the frequency
        f[i] in f, meets: R[i] < bound.
        Takes:
            - R (1d np.ndarray of floats): reflection coefficient for varying frequency
            - f (1d np.ndarray of floats): frequencies, same R.shape == f.shape
            - bound (float): bound allowing only minima a frequencies f[i] where
                             R[i] < bound.
        Returns:
            - 2d np.ndarray with shape (N, 3), where N is the number of found minima and
              each line L corresponds to start index of the convex interval (L[0]), the
              index where the minimum resides (L[1]) and the maximum index of the convex
              interval (L[2]).
    """
    indices = signal.find_peaks_cwt(1/R, widths)
    w = np.where(R[indices] < bound)
    IDX_cand = indices[w]
    result_list = np.zeros((len(IDX_cand),3),dtype=np.int)
    result_list[:,1] = IDX_cand-1
    result_list[-1,-1] = -1
    result_list[0:-1,2] = (result_list[1:,1] + result_list[0:-1,1])//2
    result_list[1:,0] = result_list[0:-1,2]
    return result_list

def find_minima2(R, f, bound, widths=[50], threshold=0.1):
    """ Find all indices i for which R[i], corresponding to the frequency
        f[i] in f, meets: R[i] < bound.
        Takes:
            - R (1d np.ndarray of floats): reflection coefficient for varying frequency
            - f (1d np.ndarray of floats): frequencies, same R.shape == f.shape
            - bound (float): bound allowing only minima a frequencies f[i] where
                             R[i] < bound.
        Returns:
            - 2d np.ndarray with shape (N, 3), where N is the number of found minima and
              each line L corresponds to start index of the convex interval (L[0]), the
              index where the minimum resides (L[1]) and the maximum index of the convex
              interval (L[2]).
    """
    indices = signal.find_peaks(1/R, height=bound, threshold=threshold)[0]
    w = np.where(R[indices] < bound)
    IDX_cand = indices[w]
    result_list = np.zeros((len(IDX_cand),3),dtype=np.int)
    result_list[:,1] = IDX_cand
    result_list[-1,-1] = -1
    result_list[0:-1,2] = (result_list[1:,1] + result_list[0:-1,1])//2
    result_list[1:,0] = result_list[0:-1,2]
    return result_list

def fit_func(coeffs, f, D, eps, tand):
    """ A Simple RLC series circuit in
        parallel to the analytically known
        impedance of a grounded dielectric
        slab of thickness D
    """
    w = 2*np.pi*f
    epsilon = eps*(1+tand*1j)
    Zd = -Z0*1j/np.sqrt(epsilon)*np.tan(w/3e8*np.sqrt(epsilon)*D)
    lendiv3, lenmod3 = divmod(len(coeffs),3)
    assert(lenmod3 == 0)
    Zges = Zd
    for i in range(lendiv3):
        i0 = i*3
        R, L, C = coeffs[i0], coeffs[i0+1], coeffs[i0+2]
        Zfss = R - 1j*w*L + 1j/(w*C)
        Zges = (1/Zfss+1/Zges)**(-1)
    Rges = (Zges-Z0)/(Zges+Z0)
    return Zges

def Rresiduals(coeffs, S11num, f, D, eps, tand):
    Zges = fit_func(coeffs, f, D, eps, tand)
    Rges = (Zges-Z0)/(Z0+Zges)
    S11num = S11num
    val = np.abs(Rges.real-S11num.real)+np.abs(Rges.imag-S11num.imag)
    return val

def Zresiduals(coeffs, S11num, f, D, eps, tand):
    Zges = fit_func(coeffs, f, D, eps, tand)
    Znum = Z0*(1+S11num)/(1-S11num)
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
    Rfit = (Zfit-Z0)/(Zfit+Z0)
    Znum = Z0*(1+S11)/(1-S11)
    print("args.plot: ", args.plot)
    if args.plot:
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
