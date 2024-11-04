
% User-defined motion data assignment function
function [displacement_vector, orientation_vector] = user_motion_data(obj, refframe_struct, motion_struct, displacement_vector, orientation_vector, tvec)

    % Initialize displacement vector, orientation vector and other variables
    if motion_struct.mot_data.vec_loc == 'n'
        nnodes = round(size(motion_struct.mot_data.vec,1)/(obj.dim*2),0);
    elseif motion_struct.mot_data.vec_loc == 'f'
        nnodes = 1;
    end

    dis_vec = zeros(obj.dim*nnodes,length(tvec));
    ori_vec = zeros(obj.dim*nnodes,length(tvec));

    motion_vector = zeros(obj.dim*nnodes,length(tvec));

    % If needed, convert input vector into an orientation vector
    if ismember(motion_struct.mot_mode,{'l','r'}) && any(motion_struct.mot_axis)
        for i = 1:length(tvec)
            motion_vector(:,i) = motion_struct.mot_axis'.*motion_struct.mot_data.vec(:,i);
        end
    else
        motion_vector = motion_struct.mot_data.vec;
    end

    % Set displacements based on data_type
    switch motion_struct.mot_data.vec_type

        case 'd' % Displacement input vector
            for i = 1:length(tvec)
                switch motion_struct.mot_mode

                    case 'l'
                        dis_vec(:,i) = motion_vector(:,i);

                    case 'r'
                        if i == 1
                            ori_vec(:,i) = motion_vector(:,i);
                        else
                            for j = 1:nnodes
                                ori_vec((j-1)*obj.dim+1:j*obj.dim,i) = matr2vec(vec2matr(motion_vector((j-1)*obj.dim+1:j*obj.dim,i)',10^-6)*vec2matr(ori_vec((j-1)*obj.dim+1:j*obj.dim,i-1)',10^-6))';
                            end
                        end

                    case 'u'
                        for j = 1:nnodes
                            dis_vec((j-1)*obj.dim+1:j*obj.dim,i) = motion_vector((j-1)*obj.dim*2+1:(j-1)*obj.dim*2+obj.dim,i);

                            if i == 1
                                ori_vec((j-1)*obj.dim+1:j*obj.dim,i) = motion_vector((j-1)*obj.dim*2+obj.dim+1:j*obj.dim*2,i);
                            else
                                ori_vec((j-1)*obj.dim+1:j*obj.dim,i) = matr2vec(vec2matr(motion_vector((j-1)*obj.dim*2+obj.dim+1:j*obj.dim*2,i)',10^-6)*vec2matr(ori_vec((j-1)*obj.dim+1:j*obj.dim,i)',10^-6))';
                            end
                        end
                end
            end

        case 'p' % Positional input vector
            for i = 1:length(tvec)

                switch motion_struct.mot_mode

                    case 'l'
                        for j = 1:nnodes
                            if i == 1
                                dis_vec((j-1)*obj.dim+1:j*obj.dim,i) = motion_vector((j-1)*obj.dim+1:j*obj.dim,i);
                            else
                                dis_vec((j-1)*obj.dim+1:j*obj.dim,i) = motion_vector((j-1)*obj.dim+1:j*obj.dim,i)-motion_vector((j-1)*obj.dim+1:j*obj.dim,i-1);
                            end
                        end

                    case 'r'
                        ori_vec(:,i) = motion_vector(:,i);
   
                    case 'u'
                        for j = 1:nnodes
                            if i == 1
                                dis_vec((j-1)*obj.dim+1:j*obj.dim,i) = motion_vector((j-1)*obj.dim*2+1:(j-1)*obj.dim*2+obj.dim,i);
                            else
                                dis_vec((j-1)*obj.dim+1:j*obj.dim,i) = motion_vector((j-1)*obj.dim*2+1:(j-1)*obj.dim*2+obj.dim,i)-motion_vector((j-1)*obj.dim*2+1:(j-1)*obj.dim*2+obj.dim,i-1);
                            end

                            ori_vec((j-1)*obj.dim+1:j*obj.dim,i) = motion_vector((j-1)*obj.dim*2+obj.dim+1:j*obj.dim*2,i);
                        end
                end
            end

        case 'v'
            for i = 1:length(tvec)
                switch motion_struct.mot_mode

                    case 'l'
                        dis_vec(:,i) = motion_vector(:,i).*obj.dt;

                    case 'r'
                        for j = 1:nnodes
                            if i == 1
                                ori_vec((j-1)*obj.dim+1:j*obj.dim,i) = (motion_vector((j-1)*obj.dim+1:j*obj.dim,i-1).*obj.dt)'./norm(motion_vector((j-1)*obj.dim+1:j*obj.dim,i-1).*obj.dt);
                            else
                                ori_vec((j-1)*obj.dim+1:j*obj.dim,i) = matr2vec(vec2matr((motion_vector((j-1)*obj.dim+1:j*obj.dim,i-1).*obj.dt)'./norm(motion_vector((j-1)*obj.dim+1:j*obj.dim,i-1).*obj.dt),10^-6)*vec2matr(ori_vec((j-1)*obj.dim+1:j*obj.dim,i)',10^-6))';
                            end
                        end
   
                    case 'u'
                        for j = 1:nnodes
                            dis_vec((j-1)*obj.dim+1:j*obj.dim,i) = motion_vector((j-1)*obj.dim*2+1:(j-1)*obj.dim*2+obj.dim,i).*obj.dt;

                            if i == 1
                                ori_vec((j-1)*obj.dim+1:j*obj.dim,i) = (motion_vector((j-1)*obj.dim*2+obj.dim+1:j*obj.dim*2,i)./obj.dt)./norm(motion_vector((j-1)*obj.dim*2+obj.dim+1:j*obj.dim*2,i)./obj.dt);
                            else
                                ori_vec((j-1)*obj.dim+1:j*obj.dim,i) = matr2vec(vec2matr((motion_vector((j-1)*obj.dim*2+obj.dim+1:j*obj.dim*2,i)./obj.dt)'./norm(motion_vector((j-1)*obj.dim*2+obj.dim+1:j*obj.dim*2,i)./obj.dt),10^-6)*vec2matr(ori_vec((j-1)*obj.dim+1:j*obj.dim,i)',10^-6))';
                            end
                        end
                end
            end
    end

    % Assign displacements and orientation vectors to respective nodes and reference frames
    t0 = motion_struct.mot_data.t0;

    switch motion_struct.mot_data.vec_loc
        
        case 'n'
            for i = 1:length(tvec)
                tstep = round(t0/obj.dt,0)+i;

                displacement_vector(1:end-obj.dim,tstep) = dis_vec(:,i);

                for j = 1:length(refframe_struct.node_incl)
                    index = (j-1)*obj.dim+1:j*obj.dim;
                    orientation_vector(index,tstep)  = matr2vec(vec2matr(ori_vec(index,i)))';
                end
            end

        case 'f'
            for i = 1:length(tvec)
                tstep = round(t0/obj.dt,0)+i;
                
                displacement_vector(end-obj.dim+1:end,tstep) = dis_vec(:,i);
                orientation_vector(end-obj.dim+1:end,tstep)  = matr2vec(vec2matr(ori_vec(:,i)'))';
            end
    end
end
