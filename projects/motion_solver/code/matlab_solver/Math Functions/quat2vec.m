
% Function to convert quaternion to orientation vector
function [vec,th,n] = quat2vec(q)

    sin_t_2 = norm(q(2:4));

    if sin_t_2 == 0
        n = [1,0,0];
        cos_t_2 = 1;
    else
        n = q(2:4)/sin_t_2;
        cos_t_2 = q(1);
    end

    th = 2*atan2(sin_t_2,cos_t_2);

    vec = th*n;

end