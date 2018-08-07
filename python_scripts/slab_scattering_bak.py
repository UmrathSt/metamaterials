import numpy as np

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
        self.phase = self.k[1:-1]*self.l
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
        for i in range(rho.shape[0]-2, -1, -1):
            print("i=%i" %i)
            phasefactor = np.exp(2j*phase[i,:])
            GammaM = (rho[i,:] + GammaM*phasefactor) / (1 + rho[i,:]*GammaM*phasefactor )
            self.Gammas.append(GammaM)
        return GammaM # the left-most scattering coefficient
        
    def build_tau(self):
        """ Get the left to right transmission 
            of the stacked structure
        """
        rho = self.rho 
        phase = self.phase
        tauM = 1
        print("len self.Gammas = ", len(self.Gammas))
        for i in range(len(self.Gammas)-1, 0, -1):
            print("Building tau: i=%i" %i)
            phasefactor = np.exp(2j*phase[i-1,:])
            tauM *= (1 + self.Gammas[i-1]) / (1 + self.Gammas[i]*phasefactor)
            self.tau.append(tauM)
        tauM *= 2*self.k[-1]/(self.k[-1] + self.k[-2])
        self.tau.append(tauM)
        return tauM

        
        


if __name__ == "__main__":
    from matplotlib import pyplot as plt
    kappa = 0.1;
    epsFR4 = 4.6 
    Z0 = 376.3
    f = (np.linspace(0,20,1000)*1e9)
    epsFR4 = 4.6+1j*kappa/(2*np.pi*f*8.85e-12)
    eps = np.array([1, epsFR4, 1e8j])[:,np.newaxis]
    Zlist = np.array([Z0,Z0/np.sqrt(epsFR4),0])[:,np.newaxis]
    l = np.array([2e-3])[:,np.newaxis]
    k = np.sqrt(eps)*2*np.pi*f/3e8
    slabstack = SlabStructure(Zlist, l, k)
    R = slabstack.build_gamma()
    print(R.shape)
    T = slabstack.build_tau()
    plt.plot(f[0,:]/1e9, 20*np.log10(np.abs(R)),"r-", label="R")
    plt.plot(f[0,:]/1e9, 20*np.log10(np.abs(T)),"b-", label="T")
    plt.legend(loc="best").draw_frame(False)
    plt.xlabel("f [GHz]")
    #plt.ylabel("$20\log|S_{11}|)$")
    plt.ylabel("$|S_{11}|)$")
    plt.show()
