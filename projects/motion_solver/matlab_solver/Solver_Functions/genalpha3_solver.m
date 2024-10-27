
% Third order generalized alpha time interpolation solver
function [an1, vn1, xn1] = genalpha3_solver(dT, rhs, an, vn, xn, M, C, K, spec_rad)

    assert(spec_rad <= 1 && spec_rad >= 1/3, 'spectral radius is not within range [1/3,1]');

    alpha_m = (13+20*spec_rad-5*spec_rad^2)/(12*(spec_rad+1)^2);
    alpha_f = (1+3*spec_rad)/(2*(spec_rad+1)^2);

    gamma = 5/12+alpha_m-alpha_f;
    beta = 5/12+alpha_m-alpha_f;

    Mdyn = M*(1-alpha_m)+C*dT*gamma*(1-alpha_f)+K*dT^2*beta*(1-alpha_f);

    an1 = Mdyn\(rhs-M*an*alpha_m-C*((1-alpha_f)*(vn+dT*(1-gamma)*an)+alpha_f*vn)-K*((1-alpha_f)*(xn+dT*vn+dT^2*(0.5-beta)*an)+alpha_f*xn));
    
    vn1 = vn+dT*((1-gamma)*an+gamma*an1);
    xn1 = xn+dT*vn+dT^2*((0.5-beta)*an+beta*an1);
    
end