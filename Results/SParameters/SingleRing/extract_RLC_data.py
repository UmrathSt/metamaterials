import numpy as np
import sys
hdir = "/home/stefan/Arbeit/openEMS/metamaterials/python_scripts"
sys.path.append(hdir)
from equ_cir_fitting import Rresiduals, ZresidualsImp, fit_func
from scipy.optimize import differential_evolution
from matplotlib import pyplot as plt
import argparse

par = argparse.ArgumentParser()
par.add_argument("--fname", dest="fname", type=str)
par.add_argument("--fmin", dest="fmin", type=float)
par.add_argument("--fmax", dest="fmax", type=float)
par.add_argument("--maxiter", dest="maxiter", type=int, default=100)
par.add_argument("--popsize", dest="popsize", type=int, default=200)
par.add_argument("--D", dest="D", type=float, default=2e-3)
par.add_argument("--eps", dest="eps",type=float,default=4.2)
par.add_argument("--tand",dest="tand",type=float,default=0.02)
args = par.parse_args()

Z0 = 376.73

data = np.loadtxt(args.fname, delimiter=",")
f = data[:,0]*1e9
Znum = data[:,1:13]-1j*data[:,13:]
for idx in range(12):
    ZNUM = Znum[:,idx]
    eps, tand, D = args.eps, args.tand, args.D
    I = (np.abs(f-args.fmin)).argmin()
    J = (np.abs(f-args.fmax)).argmin()
    sumRresiduals = lambda x: ZresidualsImp(x, Z0*ZNUM[I:J], f[I:J], D, eps, tand).sum()
    solution = differential_evolution(sumRresiduals, 
            bounds=[(0.1,100),(1e-10,1e-7),(1e-14, 1e-12)],
            popsize=args.popsize,maxiter=args.maxiter)
    print("found RLC values: ", solution.x)
    ZNUM *= Z0
    Zfit = fit_func(solution.x, f, D, eps, tand)
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.set_title("theta = %i degree, R=%.3e, L=%.3e, C=%.3e" %(idx*5, *solution.x))
    ax.plot(f/1e9, Zfit.real,"r-",label="Re Zfit")
    ax.plot(f/1e9, Zfit.imag,"b-",label="Im Zfit")
    ax.plot(f/1e9, ZNUM.real,"m--",label="Re Znum")
    ax.plot(f/1e9, ZNUM.imag,"c--",label="Im Znum")
    ax.set_xlim([args.fmin/1e9, args.fmax/1e9])
    ax.set_xlabel("f [GHz]")
    ax.set_ylabel("Re($Z/Z_0$), Im($Z/Z_0$)")
    ax.legend(loc="best").draw_frame(False)
    fig.savefig("theta_%i_degree.pdf" %(idx*5), format="pdf")
