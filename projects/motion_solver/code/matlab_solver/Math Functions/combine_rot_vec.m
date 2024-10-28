% Function to combine two rotation vectors
function [r,th,n] = combine_rot_vec(vec1, vec2)

    [q1,th1,n1] = vec2quat(vec1);

    [q2,th2,n2] = vec2quat(vec2);

    qs = [ q1(1)*q2(1)-q1(2)*q2(2)-q1(3)*q2(3)-q1(4)*q2(4), ...
           q1(1)*q2(2)+q1(2)*q2(1)+q1(3)*q2(4)-q1(4)*q2(3), ...
           q1(1)*q2(3)+q1(3)*q2(1)+q1(4)*q2(2)-q1(2)*q2(4), ...
           q1(1)*q2(4)+q1(4)*q2(1)+q1(2)*q2(3)-q1(3)*q2(2) ];

    [r,th,n] = quat2vec(qs);
end