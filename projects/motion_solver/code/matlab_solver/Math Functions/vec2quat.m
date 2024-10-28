
% Function to convert orientation vector to quaternion
function [q,th,n] = vec2quat(vec)
    
    th = norm(vec);

    if th ~= 0
        n = vec(:)./th;
        q = [cos(th/2),n'.*sin(th/2)];
    else
        n = [1;0;0];
        q = [1,zeros(1,3)];
    end

end