import numpy as np
import sys
hdir = "/home/stefan_dlr/Arbeit/openEMS/metamaterials/python_scripts"
sys.path.append(hdir)
from equ_cir_fitting import Rresiduals, Zresiduals, fit_func
from scipy.optimize import differential_evolution
from matplotlib import pyplot as plt
import argparse
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--fname", dest="fname", type=str)
    parser.add_argument("--fmin", dest="fmin", type=float)
    parser.add_argument("--eps", dest="eps", type=float,default=4.6)
    parser.add_argument("--tand", dest="tand", type=float,default=0.02)
    parser.add_argument("--D", dest="D", type=float,default=0.15e-3)
    parser.add_argument("--fmax", dest="fmax", type=float)
    parser.add_argument("--popsize", dest="popsize", type=int, default=500)
    parser.add_argument("--maxiter", dest="maxiter", type=int, default=2000)
    parser.add_argument("--plot", dest="plot", type=bool, default=False)
    args = parser.parse_args()
def return_solution(fname, fmin, fmax, popsize, maxiter, plot, eps=4.6, tand=0.02, D=0.15e-3):
    """ Return a solution object of the differential_evolution routine of scipy.optimize
        giving a best approximation of a RLC circuit in parallel to the impedance of a
        grounded dielectric slab .
        Takes: 
            - fname (string): the filename for full-wave simulation data
            - fmin, fmax (floats): min and max frequency [Hz]
            - eps, tand, D (floats): real part of permittivity, loss tangent 
              and substrate thickness of the dielectric slab
            - popsize, maxiter (int): parameters for the evolution algorithm
            - plot (bool): show a plot after solving the problem
        Returns:
            scipy.optimize.differential_evolution result object
    """
    data = np.loadtxt(fname, delimiter=",")
    f, Rnum = data[:,0], data[:,1]+1j*data[:,2]
    eps, tand, D = 4.6, 0.02, 0.15e-3
    I = (np.abs(f-args.fmin)).argmin()
    J = (np.abs(f-args.fmax)).argmin()
    
    
    sumRresiduals = lambda x: Zresiduals(x, Rnum[I:J], f[I:J], D, eps, tand).sum()
    solution = differential_evolution(sumRresiduals, bounds=[(5,10),(1e-10,1e-8),(1e-13, 1e-12)],
                                        popsize=args.popsize,maxiter=args.maxiter)
    Znum = 376*(1+Rnum)/(1-Rnum)
    Zfit = fit_func(solution.x, f, D, eps, tand)
    Rfit = (Zfit-376)/(Zfit+376)
    num = Rnum
    fit = Rfit
    if args.plot:
        plt.plot(f/1e9, np.abs(num), "b-", label="$\mathcal{R}(Z_\mathrm{num})$")
        plt.plot(f/1e9, np.abs(fit), "m--", label="$\mathcal{R}(Z_\mathrm{fit})$")
        #plt.plot(f/1e9, num.real, "r-", label="$\mathcal{R}(Z_\mathrm{num})$")
        #plt.plot(f/1e9, num.imag, "b-", label="$\mathcal{R}(Z_\mathrm{num})$")
        #plt.plot(f/1e9, fit.real, "m--", label="$\mathcal{R}(Z_\mathrm{fit})$")
        #plt.plot(f/1e9, fit.imag, "c--", label="$\mathcal{R}(Z_\mathrm{fit})$")
        plt.legend(loc="best").draw_frame(False)
        plt.xlim([f[0]/1e9, f[-1]/1e9])
        plt.xlabel("f [GHz]")
        plt.ylabel("$\mathcal{R}(Z),\, \mathcal{I}(Z_\mathrm{fit})$")
        plt.show()
    return solution

if __name__ == "__main__":
    sol = return_solution(args.fname, args.fmin, args.fmax, args.popsize, 
            args.maxiter, args.plot, args.eps, args.tand, args.D)
    print(sol)
