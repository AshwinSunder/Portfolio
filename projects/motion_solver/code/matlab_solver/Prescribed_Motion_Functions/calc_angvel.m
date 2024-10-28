
% Function to calculate angular velocity
function angvel = calc_angvel(ori_vec_new,ori_vec_old,dt)

    [qnew,~,~] = vec2quat(ori_vec_new);
    [qold,~,~] = vec2quat(ori_vec_old);

    angvel(1,1) = round(2*sign(sum(qnew.*qold))*(qold(1)*qnew(2)-qold(2)*qnew(1)-qold(3)*qnew(4)+qold(4)*qnew(3))./dt,6);
    angvel(2,1) = round(2*sign(sum(qnew.*qold))*(qold(1)*qnew(3)+qold(2)*qnew(4)-qold(3)*qnew(1)-qold(4)*qnew(2))./dt,6);
    angvel(3,1) = round(2*sign(sum(qnew.*qold))*(qold(1)*qnew(4)-qold(2)*qnew(3)+qold(3)*qnew(2)-qold(4)*qnew(1))./dt,6);

end