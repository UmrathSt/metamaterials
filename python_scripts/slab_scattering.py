import numpy as np
import argparse
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--L", dest="L", type=float)
    parser.add_argument("--eps", dest="eps", type=float)
    parser.add_argument("--kappa", dest="kappa", type=float)
    parser.add_argument("--epsL", dest="epsL", type=float)
    parser.add_argument("--kappaL", dest="kappaL", type=float)
    parser.add_argument("--epsR", dest="epsR", type=float, default=1)
    parser.add_argument("--kappaR", dest="kappaR", type=float, default=56e6)
    parser.add_argument("--dB", dest="dB", type=bool, default=False)
    parser.add_argument("--semilogx", dest="semilogx", type=bool, default=False)
    args = parser.parse_args()


class SlabStructure:
    def __init__(self, Z, l, k):
        """ Initialze a slab structure of stacked impedance
            surfaces with different thicknesses
            Z0 | Z1 | Z2 | ... | ZN-1 | ZN
                 l1 | l2 | ... | lN-1  
        """
        self.Z = Z
        self.M = len(Z) - 1 # number of interfaces 
        assert Z.shape[0]-2 == l.shape[0] == k.shape[0]-2
        self.k = k
        self.l = l
        self.phase = self.k[1:-1,:]*self.l
        self.tau = Z[1:,:]*2/(Z[0:-1,:]+Z[1:,:])
        self.rho = (Z[1:,:]-Z[0:-1,:]) / (Z[1:,:]+Z[0:-1,:])
        self.Gammas = []
        self.tau = []

    def build_gamma(self):
        """ Get the scattering coefficient of the
            stacked structure by recursion
        """
        rho = self.rho 
        phase = self.phase 
        GammaM = rho[-1,:]
        self.Gammas.append(GammaM)
        # building Gamma from right to left
        for i in range(rho.shape[0]-2, -1, -1):
            print("Building Gamma: i=%i" %i)
            phasefactor = np.exp(2j*phase[i,:])
            GammaM = (rho[i,:] + GammaM*phasefactor) / (1 + rho[i,:]*GammaM*phasefactor)
            self.Gammas.append(GammaM)
        self.Gammas.reverse()
        return GammaM # the left-most scattering coefficient
        
    def build_tau(self):
        """ Get the left to right transmission 
            of the stacked structure
        """
        phase = self.phase
        tauM = 1
        print("len self.Gammas = ", len(self.Gammas))
        # the evaluation starts with the left-most transmission coefficient
        lenG = len(self.Gammas)
        for i in range(0, lenG-1):
            print("Building tau: i=%i" %i)
            phasefactor = np.exp(2j*phase[i,:])
            tauM *= (1 + self.Gammas[i]) / (1 + self.Gammas[i+1]*phasefactor)
            tauM *= np.exp(1j*phase[i,:])
            self.tau.append(tauM)
        tauM *= (1 + self.Gammas[-1])
        self.tau.append(tauM)
        return tauM

        
        


if __name__ == "__main__":
    from matplotlib import pyplot as plt
    #mdata = np.loadtxt("S11_f_UCDim_2_lz_3.5_eps_4_tand_1.txt", delimiter=",")
    #S11 = mdata[:,1]+1j*mdata[:,2]
    fmin, fmax = 0.001, 40
    f = np.linspace(fmin, fmax,500)*1e9 
    Nf = len(f) 
    Z0 = np.ones(Nf)*376.73 
    eps = np.zeros((3, Nf), dtype=np.complex128)
    Zlist = np.zeros((3, Nf), dtype=np.complex128)
    eps[0,:] = args.epsL + 1j*args.kappaL/(2*np.pi*f*8.85e-12)
    eps[1,:] = args.eps + 1j*args.kappa/(2*np.pi*f*8.85e-12) 
    eps[2,:] = args.epsR + 1j*args.kappaR/(2*np.pi*f*8.85e-12) 
    Zlist[:,:] = Z0/np.sqrt(eps[0,:]), Z0/np.sqrt(eps[1,:]), Z0/np.sqrt(eps[2,:])
    l = np.array([args.L])[:,np.newaxis]
    k = np.sqrt(eps)*2*np.pi*f/3e8
    slabstack = SlabStructure(Zlist, l, k)
    R = slabstack.build_gamma()
    T = slabstack.build_tau()
    RR, TT = np.abs(R)**2, np.abs(T)**2
    if args.dB:
        RR, TT = 10*np.log10(RR), 10*np.log10(TT)
    doplot = plt.plot
    if args.semilogx:
        doplot = plt.semilogx
    doplot(f/1e9, RR,"b-", label="S11, L=50 mm")
    doplot(f/1e9, TT,"r-", label="S21, L=50 mm")
    result = np.zeros((len(f), 5))
    result[:,0] = f
    result[:,1] = np.real(R)
    result[:,2] = np.imag(R)
    result[:,3] = np.real(T)
    result[:,4] = np.imag(T)
    header = "# Scattering and Transmission from a %.2f FR4 slab with eps = %.2f, kappa=%.2f" %(args.L, args.eps, args.kappa)
    header += " in background medium of eps = %.2f kappa = %.2f" %(args.epsR, args.kappaR)
    np.savetxt("slab_scattering", result, delimiter=",", header=header)
    plt.legend(loc="best").draw_frame(False)
    plt.xlabel("f [GHz]", fontsize=14)
    ylabel = "$|S11|^2,|S12|^2$"
    if args.dB:
        ylabel += " dB"
    plt.ylabel(ylabel, fontsize=14)
    plt.title("Streuung an einer L=%.1f mm dicken Schicht, $\epsilon$=%.1f + $\mathrm{i}$%.2f/(2$\pi f \epsilon_0$)" %(args.L*1000, args.eps, args.kappa))
    plt.xlim([fmin, fmax])
    plt.grid()
    plt.savefig("streuung_dielektrische_Schicht.pdf", format="pdf")
    plt.show()
