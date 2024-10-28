
% Function to solve simple Runge-Kutta 4th order explicit time integration method
function [an1, vn1, xn1] = erk45_solver(dT, rhs, vn, xn, M, C, K, epsilon)

    M_copy = M;
    for i = 1:length(M_copy)
        if all(M(:,i) == 0) && all(M(i,:)== 0)
            M_copy(i,i) = 1e-4;
        end
    end

    fun = @(t,y) [ y(length(y)/2+1:end,1) ; ...
                 M_copy\(rhs-C*y(length(y)/2+1:end,1)-K*y(1:length(y)/2,1))];
    t = 0;
    h = dT;
    yn = [xn;vn];
    yn1 = yn;

    while t < dT
        h = min(h,2-t);

        k1 = h*fun(t,yn1);

        k2 = h*fun(t+h/4, yn1+k1/4);

        k3 = h*fun(t+3*h/8, yn1+3*k1/32+9*k2/32);

        k4 = h*fun(t+12*h/13, yn1+1932*k1/2197-7200*k2/2197+7296*k3/2197);

        k5 = h*fun(t+h, yn1+439*k1/216-8*k2+3680*k3/513-845*k4/4104);

        k6 = h*fun(t+h/2, yn1-8*k1/27+2*k2-3544*k3/2565+1859*k4/4104-11*k5/40);

        yn_1 = yn1 + 25*k1/216+1408*k3/2565+2197*k4/4104-k5/5;
        yn_2 = yn1 + 16*k1/135+6656*k3/12825+28561*k4/56430-9*k5/50+2*k6/55;

        R = norm(abs(yn_1-yn_2)/h);
        delta = 0.84*(epsilon/R).^(1/4);
        disp(t)
        disp(R)

        if R <= epsilon
            t = t+h;
            yn1 = yn_1;
            h = delta*h;
        else
            h = delta*h;
        end
    end
    xn1 = yn1(1:length(yn1)/2,1);
    vn1 = yn1(length(yn1)/2+1:end,1);
    an1 = (vn1-vn)/dT;
end