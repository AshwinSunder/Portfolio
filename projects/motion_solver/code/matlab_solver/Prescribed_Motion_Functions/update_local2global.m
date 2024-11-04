
% Function to update reference frame values
function [displacement_global,orientationmatrix_global,velocity_global,angularvelocity_global] = update_local2global(obj,displacement_local,orientationvec_local,displacement_global,orientationmatrix_global,velocity_global,angularvelocity_global,parent_tag)
 %   Short Description
    %% Input
    %
    %
    %% Output
    %
    %
    
    %% Find all children for the current reference frame and iterate through all children
    child_tags = obj.reference_frame_table.ref_tag(string(obj.reference_frame_table.parent_tag) == string(parent_tag));

    for i = 1:length(child_tags)
        current_tag = child_tags(i);

        parent_position_G = zeros(obj.dim,length(obj.tvec_sim));
        node_position_G   = zeros(obj.dim,length(obj.tvec_sim));
        frame_position_G  = zeros(obj.dim,length(obj.tvec_sim));

        % For reference frame origin node
        % Set frame variables
        localID      = find(matches(obj.reference_frame_table.ref_tag,current_tag));
        node_incl    = obj.reference_frame_table.node_incl{localID};

        for j = 1:length(obj.tvec_sim)

            % Get parent reference frame data
            [parent_position_G, parent_displacement_G, parent_orientationmatrix_G, parent_rotmatrix_G, parent2global, parent2frame, ~] = get_parent_data(obj, displacement_global, orientationmatrix_global, parent_position_G, parent_tag, current_tag, j);

            % Get current reference frame data
            [frame_position_G, ~, ~, frame_initial_orientation_G, frameID] = get_data(obj, frame_position_G, displacement_global, orientationmatrix_global, current_tag, "", j);

            frame_orientationmatrix_L = vec2matr(orientationvec_local{localID}(end-2:end,j)',10^-18);
            frame_displacement_L      = displacement_local{localID}(end-2:end,j);

            frame_position_vector_G = frame_position_G(:,j)-parent_position_G(:,j);
     
            % Calculate local offsets and orientaitions with respect to parent reference frame
            frame_displacement_G     = parent_rotmatrix_G*(parent2global*frame_displacement_L);
            frame_displacement_by_parentrotation_G  = parent_rotmatrix_G*frame_position_vector_G-frame_position_vector_G;
     
            displacement_global{frameID,j}      = frame_displacement_G+frame_displacement_by_parentrotation_G+parent_displacement_G;
            orientationmatrix_global{frameID,j} = parent_orientationmatrix_G*(parent2frame*frame_orientationmatrix_L);
            
            % For node_incl
            % Get updated current reference frame data
            [frame_position_G, frame_displacement_G, frame_orientationmatrix_G, frame_rotmatrix_G, global2frame, ~, ~] = get_parent_data(obj, displacement_global, orientationmatrix_global, frame_position_G, current_tag, "", j);

            if j == 1
                velocity_global{localID,j}        = zeros(obj.dim,1);
                angularvelocity_global{localID,j} = zeros(obj.dim,1);
            else
                frame_orientationmatrix_L_old = vec2matr(orientationvec_local{localID}(end-2:end,j-1)',10^-18);

                frame_angularvelocity_L = calc_angvel(matr2vec(frame_orientationmatrix_L),matr2vec(frame_orientationmatrix_L_old),obj.dt);
    
                [~, ~, ~, ~, parentID] = get_data(obj, frame_position_G, displacement_global, orientationmatrix_global, parent_tag, "", j); 
    
                parent_angularvelocity_G = angularvelocity_global{parentID,j};
    
                frame_velocity_G        = displacement_global{frameID,j}./obj.dt;
                frame_angularvelocity_G = parent_angularvelocity_G+parent_orientationmatrix_G*(parent2frame*frame_angularvelocity_L);%
    
                velocity_global{frameID,j}        = frame_velocity_G;
                angularvelocity_global{frameID,j} = frame_angularvelocity_G;
            end

            for k = 1:length(node_incl)
                % Set node variables
                nodeID          = node_incl(k);
                node_position_L = obj.init_cond((nodeID-1)*obj.dim*2+1:(nodeID-1)*obj.dim*2+obj.dim);
                index           = (k-1)*obj.dim+1:k*obj.dim;

                node_orientationmatrix_L = vec2matr(orientationvec_local{localID}(index,j)',10^-18);
                node_displacement_L      = displacement_local{localID}(index,j);
    
                if j == 1
                    node_position_G(:,j) = node_position_L;
                else
                    node_position_G(:,j) = node_position_G(:,j-1)+displacement_global{nodeID,j-1};
                end

                node_position_vector_G = node_position_G(:,j)-frame_position_G(:,j);

                % Calculate local offsets and orientaitions with respect to parent reference frame
                node_displacement_G                   = frame_rotmatrix_G*(global2frame\node_displacement_L);
                node_displacement_by_framerotation_G  = frame_rotmatrix_G*node_position_vector_G-node_position_vector_G;
         
                displacement_global{nodeID,j}      = node_displacement_G+node_displacement_by_framerotation_G+frame_displacement_G;
                orientationmatrix_global{nodeID,j} = frame_orientationmatrix_G*node_orientationmatrix_L;

                if j == 1
                    velocity_global{nodeID,j}        = zeros(obj.dim,1);
                    angularvelocity_global{nodeID,j} = zeros(obj.dim,1);
                else
                    node_orientationmatrix_L_old = vec2matr(orientationvec_local{localID}(index,j-1)',10^-18);
    
                    node_angularvelocity_L = calc_angvel(matr2vec(node_orientationmatrix_L),matr2vec(node_orientationmatrix_L_old),obj.dt);
        
                    %

                    node_angularvelocity_G = frame_angularvelocity_G+frame_orientationmatrix_G*node_angularvelocity_L;
        
                    velocity_global{nodeID,j} = displacement_global{nodeID,j}./obj.dt;
                    angularvelocity_global{nodeID,j} = node_angularvelocity_G;
                end

            end
        end
   
        % Perform same offest and orientation matrix updates for all children
        [displacement_global,orientationmatrix_global,velocity_global,angularvelocity_global] = update_local2global(obj,displacement_local,orientationvec_local,displacement_global,orientationmatrix_global,velocity_global,angularvelocity_global,current_tag);
    end
end

%% Function to return parent data
function [parent_position_G, parent_displacement_G, parent_orientationmatrix_G, parent_rotmatrix_G, parent2global, parent2local, parentID] = get_parent_data(obj, displacement_global, orientationmatrix_global, parent_position_G, parent_tag, current_tag, tstep)

    if string(parent_tag) ~= "0"
        parent_index                 = matches(obj.reference_frame_table.ref_tag,parent_tag);
        parent2global                = inv(obj.reference_frame_table.orientation_global{parent_index});
    else
        parent2global                = eye(obj.dim);
    end

    [parent_position_G, parent2local, parent_rotmatrix_G, ~, parentID] = get_data(obj, parent_position_G, displacement_global, orientationmatrix_global, parent_tag, current_tag, tstep);

    parent_displacement_G      = displacement_global{parentID,tstep};
    parent_orientationmatrix_G = orientationmatrix_global{parentID,tstep};
end

%% Function to return current reference frame data
function [position_G, local2child, rotmatrix_G, initial_orientation_G, currID] = get_data(obj, position_G, displacement_G, orientation_G, ref_tag, child_tag, tstep)

    if string(ref_tag) ~= "0"
        index    = find(matches(obj.reference_frame_table.ref_tag,ref_tag));
        origin_G = obj.reference_frame_table.origin_global(index,:)';
        initial_orientation_G = obj.reference_frame_table.orientation_global{index};

        if ismember(child_tag,string(1:obj.nnodes))
            currID = str2double(child_tag);
        else
            currID = obj.nnodes+index+1;
        end
    else
        currID = obj.nnodes+1;
        origin_G = zeros(obj.dim,1);
        initial_orientation_G = eye(obj.dim);
    end   

    if tstep == 1
        position_G(:,tstep) = origin_G;
        if ismember(child_tag,string(1:obj.nnodes))
            rotmatrix_G = eye(obj.dim);
        else
            rotmatrix_G = orientation_G{currID,tstep}/initial_orientation_G;
        end
    else
        position_G(:,tstep) = position_G(:,tstep-1)+displacement_G{currID,tstep-1};
        if ismember(child_tag,string(1:obj.nnodes))
            rotmatrix_G = eye(obj.dim);
        else
            rotmatrix_G = orientation_G{currID,tstep}/orientation_G{currID,tstep-1};
        end
    end

    if child_tag ~= ""
        index_ch = matches(obj.reference_frame_table.ref_tag,child_tag);
        local2child = obj.reference_frame_table.orientation{index_ch};
    else
        local2child = eye(obj.dim);
    end
end
