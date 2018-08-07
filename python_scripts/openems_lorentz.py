import numpy as np
from matplotlib import pyplot as plt


def epsilon(w, params, kappa):
    """ the Lorentz-Model like it is implemented
        in openEMS
    """
    assert len(params)%3 == 0
    npoles = len(params)//3
    params = params.reshape(3,npoles)
    params = params[np.newaxis,:,:]
    eps_r = 1-1j*kappa/(w*8.85e-12)
    w = w[:, np.newaxis]
    eps_r -= np.sum(params[:,0,:]**2 /
   (w**2 - params[:,1,:]**2 - 1j*w*params[:,2,:]) 
            ,axis=1)
    return eps_r



if __name__ == "__main__":
    fig = plt.figure()
    ax1 = fig.add_subplot(211)
    ax2 = fig.add_subplot(212)
    w = np.logspace(8,10,100)
    params = np.array([1.84e11, 2.3e11, 3e8])
    kappa = 1
    eps = epsilon(w, params, kappa)
    ax1.plot(w/(2*np.pi*1e9), eps.real)
    ax2.plot(w/(2*np.pi*1e9), eps.imag)
    ax1.set_ylim([1,2])
    plt.show()
