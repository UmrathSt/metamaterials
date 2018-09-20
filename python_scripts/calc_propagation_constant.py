import numpy as np
from matplotlib import pyplot as plt


def calcPropagationConstant(w, eps, kappa):
    EPS0 = 8.85e-12
    c0 = 2.998e8
    MUE0 = 4*np.pi*1e-7
    alpha = w*np.sqrt(eps)/c0/np.sqrt(2)*np.sqrt(1+np.sqrt(1+(kappa/(w*eps*EPS0))**2))
    beta  = w*MUE0*kappa/(2*alpha)
    return alpha, beta

if __name__ == "__main__":
    eps = 4.6
    kappa = 0.05
    f = np.linspace(3,20,100)
    w = 2*np.pi*1e9*f
    
    alpha, beta = calcPropagationConstant(w, eps, kappa)
    
    plt.plot(f, np.exp(-2e-3*beta))
    plt.show()
