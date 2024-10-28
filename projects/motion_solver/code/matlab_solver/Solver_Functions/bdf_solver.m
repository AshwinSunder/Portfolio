
% Backwards differentiation formula time interpolation solver
function [an1, vn1, xn1] = bdf_solver(dT, rhs, vn, xn, M, C, K, order)

    if nargin < 8
        order = 2;
    else
        assert(ismember(order, 1:6), 'Order of newmark solver must be between 1 and 6');
    end

    bdf{1} = [1        1                                             ];
    bdf{2} = [4/3     -1/3     2/3                                   ];
    bdf{3} = [18/11   -9/11    2/11     6/11                         ];
    bdf{4} = [48/25   -36/25   16/25   -3/25    12/25                ];
    bdf{5} = [300/137 -300/137 200/137 -75/137  12/137  60/137       ];
    bdf{6} = [360/147 -450/147 400/147 -225/147 72/147 -10/147 60/147];

    yn = [xn;vn];
    yn1 = zeros(length(yn),1);
    M_copy = M;
    for i = 1:length(M_copy)
        if all(M(:,i) == 0) && all(M(i,:)== 0)
            M_copy(i,i) = 1e-4;
        end
    end

    fun = @(y) [ y(length(y)/2+1:end,1) ; ...
                 M_copy\(rhs-C*y(length(y)/2+1:end,1)-K*y(1:length(y)/2,1))];

    for i = 1:order
        yn1 = yn1+bdf{order}(i).*yn(:,end-i+1);
    end

    yn1 = yn1+bdf{order}(end)*dT.*fun(yn(:,end));

    xn1 = yn1(1:length(yn1)/2,1);
    vn1 = yn1(length(yn1)/2+1:end,1);
    an1 = (vn1-vn(:,end))/dT;
end
