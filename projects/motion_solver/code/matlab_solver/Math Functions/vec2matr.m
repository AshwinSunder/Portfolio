
% Function to convert an orientation vector to an orientation matrix
function R = vec2matr(vec,tol)

    theta = norm(vec);

    if theta >= 10^-6
        u = vec./theta;
        u = u(:);
        w1 = u(1);
        w2 = u(2);
        w3 = u(3);
        
        A = [  0, -w3,   w2;...
              w3,   0,  -w1;...
             -w2,  w1,    0];
         
        B = u*u';
         
        alpha   = cos(theta);
        beta    = sin(theta);
        gamma   = 1-alpha;
        
        R = eye(3,'like',vec)*alpha+beta*A+gamma*B;

        if nargin > 1
            R(abs(R) < tol) = 0;
        end

    else
        R = eye(3,'like',vec);
    end
end
