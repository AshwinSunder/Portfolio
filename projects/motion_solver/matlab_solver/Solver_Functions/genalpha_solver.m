
% Generalized alpha time interpolation solver
function [an1, vn1, xn1] = genalpha_solver(dT, rhs, an, vn, xn, M, C, K, spec_rad)

    if nargin < 9
        spec_rad = 9/11;
    else
        assert(spec_rad <= 1 && spec_rad > 0, 'spectral radius is not within range (0,1]');
    end
    
    alpha_m = (2*spec_rad-1)/(spec_rad+1);
    alpha_f = spec_rad/(spec_rad+1);

    gamma = 0.5-alpha_m+alpha_f;
    beta = 0.25*(1-alpha_m+alpha_f)^2;

    Mdyn = M*(1-alpha_m)+C*dT*gamma*(1-alpha_f)+K*dT^2*beta*(1-alpha_f);

    an1 = Mdyn\(rhs-M*an*alpha_m-C*((1-alpha_f)*(vn+dT*(1-gamma)*an)+alpha_f*vn)-K*((1-alpha_f)*(xn+dT*vn+dT^2*(0.5-beta)*an)+alpha_f*xn));

    % options = optimoptions('fsolve','Algorithm','levenberg-marquardt','Display','None');
    % fun = @(x) genalpha(x, dT, an, vn, xn, M, C, K, rhs, alpha_m, alpha_f);
    % 
    % an1 = fsolve(fun, an, options); 
    
    vn1 = vn+dT*((1-gamma)*an+gamma*an1);
    xn1 = xn+dT*vn+dT^2*((0.5-beta)*an+beta*an1);
    
end

%% 

% function eq = genalpha(x, dT, an, vn, xn, M, C, K, rhs, alpha_m, alpha_f)
% 
%     gamma = 0.5-alpha_m+alpha_f;
%     beta = 0.25*(1-alpha_m+alpha_f)^2;
% 
%     xn1 = xn+dT*vn+dT^2*((0.5-beta)*an+beta*x);
%     vn1 = vn+dT*((1-gamma)*an+gamma*x);
% 
%     df = (1-alpha_f)*xn1+alpha_f*xn;
%     vf = (1-alpha_f)*vn1+alpha_f*vn;
%     am = (1-alpha_m)*x+alpha_m*an;
% 
%     eq = M*am+C*vf+K*df-rhs;
% end