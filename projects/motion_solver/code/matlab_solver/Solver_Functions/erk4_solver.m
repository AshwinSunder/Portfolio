
% Function to solve simple Runge-Kutta 4th order explicit time integration method
function [an1, vn1, xn1] = erk4_solver(dT, rhs, vn, xn, M, C, K)

    M_copy = M;
    for i = 1:length(M_copy)
        if all(M(:,i) == 0) && all(M(i,:)== 0)
            M_copy(i,i) = 1e-4;
        end
    end

    fun = @(y) [ y(length(y)/2+1:end,1) ; ...
                 M_copy\(rhs-C*y(length(y)/2+1:end,1)-K*y(1:length(y)/2,1))];
    yn = [xn;vn];

    k1 = dT*fun(yn);

    k2 = dT*fun(yn+k1/2);

    k3 = dT*fun(yn+k2/2);
    
    k4 = dT*fun(yn+k3);

    yn1 = yn+(1/6)*(k1+2*k2+2*k3+k4);

    xn1 = yn1(1:length(yn1)/2,1);
    vn1 = yn1(length(yn1)/2+1:end,1);
    an1 = (vn1-vn)/dT;

end