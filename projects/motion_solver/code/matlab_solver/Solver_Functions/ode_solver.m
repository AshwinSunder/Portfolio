
% Ode solver
function [an1, vn1, xn1] = ode_solver(dT, rhs, vn, xn, M, C, K, solver)

    M_copy = M;
    for i = 1:length(M_copy)
        if all(M(:,i) == 0) && all(M(i,:)== 0)
            M_copy(i,i) = 1e-4;
        end
    end

    warning('off', 'MATLAB:singularMatrix');
    warning('off', 'MATLAB:nearlySingularMatrix');
    options = odeset('RelTol', 1e-5, 'Abstol', 1e-4);

    odefun = @(t,y) [y(length(y)/2+1:end,1); ...
                     M_copy\(rhs-C*y(length(y)/2+1:end,1)-K*y(1:length(y)/2,1))];

    if contains(solver, '45')
        [~, yn1] = ode45(odefun, [0 dT], [xn;vn], options);
    elseif contains(solver, '23')
        [~, yn1] = ode23s(odefun, [0 dT], [xn;vn], options);
    end
    vn1 = yn1(end,length(yn1)/2+1:end)';
    xn1 = yn1(end,1:length(yn1)/2)';
    an1 = (vn1-vn)./dT;
end

%% 

% function dydt = odefun(t, y, M, C, K, rhs)
% 
%     dydt = zeros(length(y),1);
% 
%     dydt(1:length(y)/2,1) = y(length(y)/2+1:end,1);    
%     dydt(length(y)/2+1:end,1) = M\(rhs-C*y(length(y)/2+1:end,1)-K*y(1:length(y)/2,1));
% 
% end
