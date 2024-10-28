% Function to calculate prescribed values for all nodes and reference frames
function set_prescribed_val(obj)
 %   Short Description
    %% Input
    %
    %
    %% Output
    %
    %
 
    %% Calculate displacements for each motion
    % Set displacements and time vectors for each motion
    orientationvector_motion = cell(height(obj.motion_table),1);
    displacement_motion      = cell(height(obj.motion_table),1);

    for i = 1:height(obj.motion_table) 
        ref_tag   = obj.motion_table.ref_frame(i);
        node_incl = obj.reference_frame_table.node_incl{matches(obj.reference_frame_table.ref_tag,ref_tag)};

        t0   = obj.motion_table.mot_data{i}.t0;
        tf   = obj.motion_table.mot_data{i}.tf;
        tvec = 0:obj.dt:(tf-t0);

        % Initialize offset and orientation vector matrices
        displacement_motion{i}      = zeros(obj.dim*(length(node_incl)+1),length(obj.tvec_sim));
        orientationvector_motion{i} = zeros(obj.dim*(length(node_incl)+1),length(obj.tvec_sim));

        refframe_struct = table2struct(obj.reference_frame_table(matches(obj.reference_frame_table.ref_tag, obj.motion_table.ref_frame(i)),:));
        motion_struct   = table2struct(obj.motion_table(i,:));

        % For different types of motion modes, call different functions to calculate offsets and orientation vectors
        switch obj.motion_table.mot_mode(i) 

            case {'l','r'} % Linear and rotational modes    
                [displacement_motion{i}, orientationvector_motion{i}, obj.motion_table.mot_data{i}] = prescribed_motion_1d(obj, refframe_struct, motion_struct, displacement_motion{i}, orientationvector_motion{i}, tvec);

            case 'e' % Mode shapes
                [displacement_motion{i}, orientationvector_motion{i}] = eigenmotion(obj, refframe_struct, motion_struct, displacement_motion{i}, orientationvector_motion{i}, tvec);
            
            case 'u' % User-input mode
                [displacement_motion{i}, orientationvector_motion{i}] = user_motion_data(obj, refframe_struct, motion_struct, displacement_motion{i}, orientationvector_motion{i}, tvec);
            
            case 'f' % Custom function mode
                initial_data.dis = obj.dis(:,1);
                initial_data.pos = obj.pos(:,1);
                initial_data.vel = obj.vel(:,1);
                initial_data.nnodes = obj.nnodes;
                initial_data.dim = obj.dim;

                [output, obj.motion_table.mot_data{i}] = custom_func(input_data_type, obj.nnodes, obj.motion_table.mot_data{i}, obj.tvec_sim, initial_data);

                tvec{i} = output.time_data.tveco;
                displacement_motion{i}      = [output.scalar_data.dis;zeros(obj.dim,length(tvec{i}))];
                orientationvector_motion{i} = [output.scalar_data.ang;zeros(obj.dim,length(tvec{i}))];
        end
    end
    
    %% Save displacements and rotations from each motion to their respective reference frames
    % Create arrays to store displacements and orientation matrices
    orientationvector_refframe = cell(height(obj.reference_frame_table),1);
    displacement_refframe      = cell(height(obj.reference_frame_table),1);

    for i = 1:height(obj.reference_frame_table)
        orientationvector_refframe{i} = zeros(obj.dim*(length(obj.reference_frame_table.node_incl{i})+1),length(obj.tvec_sim));
        displacement_refframe{i}      = zeros(obj.dim*(length(obj.reference_frame_table.node_incl{i})+1),length(obj.tvec_sim));
    end

    % Loop through each motion and save displacements and orientation vectors based on the 'ref_frame' tag
    for i = 1:height(obj.motion_table)
        refID       = matches(obj.reference_frame_table.ref_tag,obj.motion_table.ref_frame{i});
        node_incl   = obj.reference_frame_table.node_incl{refID};

        for j = 1:length(obj.tvec_sim)

            % For all node_incl
            for k = 1:length(node_incl)
                index = (k-1)*obj.dim+1:k*obj.dim;

                displacement_vector                   = displacement_motion{i}(index,j);
                displacement_refframe{refID}(index,j) = displacement_refframe{refID}(index,j)+displacement_vector;

                rotation_matrix                            = vec2matr(orientationvector_motion{i}(index,j)',10^-6);
                orientationvector_refframe{refID}(index,j) = matr2vec(rotation_matrix*vec2matr(orientationvector_refframe{refID}(index,j)',10^-6));
            end

            % For reference frame origin node
            displacement_vector                       = displacement_motion{i}(end-2:end,j);
            displacement_refframe{refID}(end-2:end,j) = displacement_refframe{refID}(end-2:end,j)+displacement_vector;

            rotation_matrix                                = vec2matr(orientationvector_motion{i}(end-2:end,j)',10^-6);
            orientationvector_refframe{refID}(end-2:end,j) = matr2vec(rotation_matrix*vec2matr(orientationvector_refframe{refID}(end-2:end,j)',10^-6));
        end
    end

    %% Update reference frames to calculate global values for each node
    % Initialize global displacement and orientation matrix arrays
    displacement_global      = cell(obj.nnodes+height(obj.reference_frame_table)+1,length(obj.tvec_sim));
    orientationmatrix_global = cell(obj.nnodes+height(obj.reference_frame_table)+1,length(obj.tvec_sim));
    velocity_global          = cell(obj.nnodes+height(obj.reference_frame_table)+1,length(obj.tvec_sim));
    angularvelocity_global   = cell(obj.nnodes+height(obj.reference_frame_table)+1,length(obj.tvec_sim));

    for i = 1:obj.nnodes+height(obj.reference_frame_table)+1
        for j = 1:length(obj.tvec_sim)
            displacement_global{i,j}      = zeros(obj.dim,1);
            orientationmatrix_global{i,j} = eye(obj.dim);
            velocity_global{i,j}          = zeros(obj.dim,1);
            angularvelocity_global{i,j}   = zeros(obj.dim,1);
        end
    end

    % Call the 'update_ref' function which updates displacements and orientation matrices based on parent-child hierarchy
    [displacement_global,orientationmatrix_global,velocity_global,angularvelocity_global] = update_local2global(obj,displacement_refframe,orientationvector_refframe,displacement_global,orientationmatrix_global,velocity_global,angularvelocity_global,num2str(0));

    % Initialize global position and velocity arrays
    position_global_final = [reshape(obj.init_cond(1:obj.dof),[],1) zeros(obj.dof,length(obj.tvec_sim)-1)];
    velocity_global_final = [reshape(obj.init_cond(obj.dof+1:end),[],1) zeros(obj.dof,length(obj.tvec_sim)-1)];

    %% For each node, calculate and save global positions, velocities, orientation vectors and angular velocities
    for i = 1:obj.nnodes
        translational_dof_index = (i-1)*obj.dim*2+1:(i-1)*obj.dim*2+obj.dim;
        rotational_dof_index    = (i-1)*obj.dim*2+obj.dim+1:i*obj.dim*2;

        % Rotations
        for j = 1:length(obj.tvec_sim)
            for k = 1:height(obj.reference_frame_table)
                if ismember(i,obj.reference_frame_table.node_incl{k})
                    glob_mat = obj.reference_frame_table.orientation_global{k};
                end
            end
            position_global_final(rotational_dof_index,j) = matr2vec(orientationmatrix_global{i,j})';

            % Angular velocities
            velocity_global_final(rotational_dof_index,j) = angularvelocity_global{i,j};

            % Positions and Velocities
            if j == 1
                position_global_final(translational_dof_index,j) = obj.init_cond(translational_dof_index)+displacement_global{i,j};
            else
                position_global_final(translational_dof_index,j) = position_global_final(translational_dof_index,j-1)+displacement_global{i,j};
            end

            velocity_global_final(translational_dof_index,j) = velocity_global{i,j};
            
        end
    end

    %% Save reference frame global offsets and rotation matrices in the matlab_adapter object's reference_frame_table
    % Initialze arrays to save offsets and rotation matrices
    frame_position_global          = cell(height(obj.reference_frame_table),1);
    frame_orientationmatrix_global = cell(height(obj.reference_frame_table),1);

    for i = 1:height(obj.reference_frame_table)
        refframe_position   = obj.nnodes+i+1;
        frame_origin_global = obj.reference_frame_table.origin_global(i,:);

        for j = 1:length(obj.tvec_sim)
            if j == 1
                frame_position_global{i}(:,j) = displacement_global{refframe_position,j}+frame_origin_global(:);
            else
                frame_position_global{i}(:,j) = displacement_global{refframe_position,j}+frame_position_global{i}(:,j-1);
            end

            frame_orientationmatrix_global{i}(:,:,j) = orientationmatrix_global{refframe_position,j};
        end
    end

    obj.reference_frame_table.position_global          = frame_position_global;
    obj.reference_frame_table.orientationmatrix_global = frame_orientationmatrix_global;

    obj.reference_frame_table = movevars(obj.reference_frame_table,["position_global","orientationmatrix_global"],'After',width(obj.reference_frame_table));
 
    %% Assign position, velocity, displacement and acceleration values to matlab_adapter object
    for i = 1:length(obj.tvec_sim)
        obj.pos(:,i) = position_global_final(:,i); % Save positions
        obj.vel(:,i) = velocity_global_final(:,i); % Save velocities

        if i > 1
            obj.dis(:,i) = obj.pos(:,i)-obj.pos(:,i-1);
            obj.acc(:,i) = (obj.vel(:,i)-obj.vel(:,i-1))/obj.dt;
        end
    end
    disp(append("Prescribed values successfully calculated and updated in ",inputname(1)));

    %% Update the object at the save location
    obj.save_obj(true);
    
end
