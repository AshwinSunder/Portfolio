
% Newmark-beta time interpolation solver
function [an1, vn1, xn1] = newmark_solver(dT, rhs, an, vn, xn, M, C, K, order)

    if nargin < 9
        order = 1;
    else
        assert(order == 1 || order == 2, 'Order of newmark solver must be 1 or 2');
    end

    switch order
        case 1
            beta = 0.25;
            gamma = 0.5;

        case 2
            beta = 0.3025;
            gamma = 0.6;
    end

    Mdyn = (M+gamma*dT*C+beta*dT^2*K);

    an1 = Mdyn\(rhs-C*(vn+(1-gamma)*dT*an)-K*(xn+dT*vn+(1/2-beta)*dT^2*an));                    
    vn1 = vn+(1-gamma)*dT*an+gamma*dT*an1;
    xn1 = xn+dT*vn+dT^2*(0.5-beta)*an+dT^2*beta*an1;

end
