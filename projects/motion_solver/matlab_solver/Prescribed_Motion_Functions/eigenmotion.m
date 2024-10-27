
% Eigenmotion calculation function
function [displacement_vector, orientation_vector] = eigenmotion(obj, refframe_struct, motion_struct, displacement_vector, orientation_vector, tvec)

    % Initialize arrays to store eigenvalues, eigenvectors and the resulting offset
    eigen_vec = motion_struct.mot_data.eigvec(:,motion_struct.mot_data.mode); % Set eigenvectors for given mode
    eigen_val = motion_struct.mot_data.eigval(motion_struct.mot_data.mode); % Set eigenvalues for given mode

    freq = motion_struct.mot_data.freq;
    dt = obj.dt;

    if motion_struct.mot_data.damp == 0 % Check if eigenmotion is undamped
        eigen_val = 1i*imag(eigen_val);
    end

    eigenmotion_offset = zeros(length(eigen_vec),length(tvec)); % Initialize displacement vector

    for i = 1:length(tvec) % Calculate offsets
        t = tvec(i);
        eigenmotion_offset(:,i) = real(eigen_vec.*exp(eigen_val.*(t/(dt*freq))));
    end

    % Assign displacements and orientation vectors to respective nodes and reference frames
    t0 = motion_struct.mot_data.t0;

    for i = 1:length(tvec)
        tstep = round(t0/dt,0)+i;

        for j = 1:length(refframe_struct.node_incl)
            index = (j-1)*obj.dim+1:j*obj.dim;
            translational_dof_index = (j-1)*obj.dim*2+1:(j-1)*obj.dim*2+obj.dim;
            rotational_dof_index = (j-1)*obj.dim*2+obj.dim+1:j*obj.dim*2;

            if i == 1
                displacement_vector(index,tstep) = eigenmotion_offset(translational_dof_index,i);
            else
                displacement_vector(index,tstep) = eigenmotion_offset(translational_dof_index,i)-eigenmotion_offset(translational_dof_index,i-1);
            end
               
            orientation_vector(index,tstep) = eigenmotion_offset(rotational_dof_index,i);
        end
    end
end
