
% Function to create input values for motion functions
function [displacement_vector, orientation_vector, motion_data] = prescribed_motion_1d(obj, refframe_struct, motion_struct, displacement_vector, orientation_vector, tvec)
    
    motion_data = motion_struct.mot_data;

    switch lower(motion_struct.mot_type(1)) % Define rotation angle and velocity for the current time step based on the type of motion

        case 'c' % Constant motion
            d = zeros(1,length(tvec)); % Initialize output displacement scalar
            
            for i = 1:length(tvec)
                d(i) = (motion_struct.mot_data.rate*tvec(i))*exp(-motion_struct.mot_data.lambda*tvec(i));
            end

        case {'h', 'o'} % Oscillating motion
            d = zeros(1,length(tvec)); % Initialize output displacement vector

            for i = 1:length(tvec)
                d(i) = (motion_struct.mot_data.amp*(sin(motion_struct.mot_data.omega*tvec(i)+motion_struct.mot_data.phi))+motion_struct.mot_data.offset)*exp(-motion_struct.mot_data.lambda*tvec(i));  
            end
            
        case 'f' % Custom function
            nnodes = obj.nnodes;

            [output, motion_struct.mot_data] = custom_func(nnodes, motion_struct.mot_data, "scalar", tvec);
            motion_data = motion_struct.mot_data;

            tvec = output.time_data.tveco;
            d = output.scalar_data.pos;

        case 'u' % User input function
            [displacement_vector, orientation_vector] = user_motion_data(obj, refframe_struct, motion_struct, displacement_vector, orientation_vector, tvec);

            return

    end

    % Initialize displacement, position and orientation matrices for all nodes for all time steps  
    init_pos_orig = refframe_struct.origin(:); 
    pos_orig = [init_pos_orig zeros(obj.dim,length(tvec)-1)];

    ori = zeros(obj.dim*(length(refframe_struct.node_incl)+1),length(tvec));
    dis = zeros(obj.dim*(length(refframe_struct.node_incl)+1),length(tvec));

    init_pos = zeros(obj.dim*(length(refframe_struct.node_incl)),1); 

    for i = 1:length(refframe_struct.node_incl)
            node = refframe_struct.node_incl(i);
            node_pos = obj.init_cond((node-1)*obj.dim*2+1:(node-1)*obj.dim*2+obj.dim);
            init_pos((i-1)*obj.dim+1:i*obj.dim,1) = refframe_struct.orientation*(init_pos_orig+refframe_struct.orientation_global*(node_pos(:)-refframe_struct.origin_global(:)));

    end
    
    pos = [init_pos zeros(obj.dim*length(refframe_struct.node_incl),length(tvec)-1)];

    % Calculate displacements and orientations for current time step for the desired mode
    for i = 1:length(tvec)
        ax = motion_struct.mot_axis';

        switch motion_struct.mot_mode

            case 'r'
                r0 = eye(obj.dim);
                r1 = [0,-ax(3),ax(2);ax(3),0,-ax(1);-ax(2),ax(1),0];
                r2 = [ax(1)^2,ax(1)*ax(2),ax(1)*ax(3);ax(2)*ax(1),ax(2)^2,ax(2)*ax(3);ax(3)*ax(1),ax(3)*ax(2),ax(3)^2];

                r = r0.*cos(d(i))+r1.*sin(d(i))+r2.*(1-cos(d(i)));

                pos_orig(:,i) = r*init_pos_orig;
                    
                if i == 1
                    dis(end-obj.dim+1:end,i) = pos_orig(:,i)-init_pos_orig;
                else
                    dis(end-obj.dim+1:end,i) = pos_orig(:,i)-pos_orig(:,i-1);
                end

                ori(end-2:end,i) = matr2vec(r);

            case 'l'
                for j = 1:length(refframe_struct.node_incl)
                    
                    index = (j-1)*obj.dim+1:j*obj.dim;

                    pos(index,i) = refframe_struct.orientation*(d(i).*ax+refframe_struct.orientation\init_pos(index));
                end

                pos_orig(:,i) = d(i).*ax+init_pos_orig;

                if i == 1
                    dis(end-obj.dim+1:end,i) = pos_orig(:,i)-init_pos_orig(:);
                else
                    dis(end-obj.dim+1:end,i) = pos_orig(:,i)-pos_orig(:,i-1);  
                end
        end
    end

    % Assign displacements and orientation vectors to respective nodes and reference frames
    t0 = motion_struct.mot_data.t0;
    
    for i = 1:length(tvec)
        tstep = round(t0/obj.dt,0)+i;

        orientation_vector(:,tstep)  = ori(:,i);
        displacement_vector(:,tstep) = dis(:,i);
    end
end