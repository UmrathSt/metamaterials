function [alpha, beta] = calcPropagationConstant(w, eps, kappa);
% calculate the real and imaginary part of the wavevector of 
% a "plane-wave" in conductive media with (real) permittivity 
% eps and conductivity kappa at angular frequency w
physical_constants;
alpha = w.*sqrt(eps)/c0/sqrt(2).*sqrt(1+sqrt(1+(kappa./(w*eps*EPS0)).^2));
beta  = w.*MUE0*kappa./(2*alpha);
end