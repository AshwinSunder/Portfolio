
% Function to assign output argument values
function [time_data, scalar_data, scalar_final_data, vector_data, vector_final_data] = custom_func_out(func_data, mot_data, initial_data)

    % Initialize output time data
    t0o  = func_data.t0i; 
    tfo  = func_data.tfi;
    dto  = func_data.dti;

    % Save output time-related arguments' values
    for j = 1:length(mot_data.arg_out)

        if contains(mot_data.arg_out{j}, 't0') || contains(lower(mot_data.arg_out{j}), 'start')
            t0o = mot_data.val_out{j};
            continue
        end
        if contains(mot_data.arg_out{j}, 'tf') || contains(lower(mot_data.arg_out{j}), 'end')
            tfo = mot_data.val_out{j};
            continue
        end
        if contains(mot_data.arg_out{j}, 'tvec')
            tveco = mot_data.val_out{j};
            tfo = tveco(end);
            t0o = tveco(1);
            continue
        end
        if contains(lower(mot_data.arg_out{j}), 'dt') || contains(lower(mot_data.arg_out{j}), 'step')
            dto = mot_data.val_out{j};
            continue
        end
    end

    % Create final time vector
    tveco = t0o:dto:tfo; 

    % Initialize output data
    if nargin > 2

        for j = 1:initial_data.nnodes
            disi(j:j+2,1)    = initial_data.dis((j-1)*initial_data.dim*2+1:(j-1)*initial_data.dim*2+3,1);
            posi(j:j+2,1)    = initial_data.pos((j-1)*initial_data.dim*2+1:(j-1)*initial_data.dim*2+3,1);
            veli(j:j+2,1)    = initial_data.vel((j-1)*initial_data.dim*2+1:(j-1)*initial_data.dim*2+3,1);
            roti(j:j+2,1)    = initial_data.dis((j-1)*initial_data.dim*2+4:j*initial_data.dim*2,1);
            angi(j:j+2,1)    = initial_data.pos((j-1)*initial_data.dim*2+4:j*initial_data.dim*2,1);
            angveli(j:j+2,1) = initial_data.vel((j-1)*initial_data.dim*2+4:j*initial_data.dim*2,1);
        end

        dis    = [disi zeros(length(disi),length(tveco)-1)]; 
        vel    = [veli zeros(length(veli),length(tveco)-1)];
        rot    = [roti zeros(length(roti),length(tveco)-1)];
        angvel = [angveli zeros(length(angveli),length(tveco)-1)];       
        pos    = zeros(length(posi),length(tveco))+posi;
        ang    = zeros(length(angi),length(tveco))+angi;
    else
        dis    = zeros(1,length(tveco));
        pos    = zeros(1,length(tveco));
        vel    = zeros(1,length(tveco));
        rot    = zeros(1,length(tveco));
        ang    = zeros(1,length(tveco));
        angvel = zeros(1,length(tveco));
    end

    for j = 1:length(mot_data.arg_out)

        if contains(lower(mot_data.arg_out{j}), 'dis')
            dis = mot_data.val_out{j};

            for k = 2:length(tveco)
                pos(:,k) = pos(:,k-1)+dis(:,k);
            end

            if all(contains(mot_data.arg_out, 'vel') == 0)
                for k = 2:length(tveco)
                    vel(:,k) = dis(:,k)./(tveco(k)-tveco(k-1));
                end
            end
            continue
        end
        if contains(lower(mot_data.arg_out{j}), 'pos')
            for i = 1:size(mot_data.arg_out{j},1)
                pos(i,:) = mot_data.val_out{j};
            end
            
            for k = 2:length(tveco)
                dis(:,k) = pos(:,k)-pos(:,k-1);
            end

            if all(contains(mot_data.arg_out, 'vel') == 0)
                for k = 2:length(tveco)
                    vel(:,k) = dis(:,k)./(tveco(k)-tveco(k-1));
                end
            end
            continue
        end
        if contains(lower(mot_data.arg_out{j}), 'vel')
            vel = mot_data.val_out{j};

            if all(contains(mot_data.arg_out, 'dis') == 0) && all(contains(mot_data.arg_out, 'pos') == 0)
                for k = 2:length(tveco)
                    dis(:,k) = vel(:,k)*(tveco(k)-tveco(k-1));
                    pos(:,k) = pos(:,k-1)+dis(:,k);
                end
            end
            continue
        end
        if contains(lower(mot_data.arg_out{j}), 'rot') 
            rot = mot_data.val_out{j};
            
            for k = 2:length(tveco)
                ang(:,k) = ang(:,k-1)+rot(:,k);
            end
                
            if all(contains(mot_data.arg_out, 'vel') == 0)
                for k = 2:length(tveco)
                    angvel(:,k) = rot(:,k)./(tveco(k)-tveco(k-1));
                end
            end
            continue
        end
        if contains(lower(mot_data.arg_out{j}), 'ang') && ~contains(lower(mot_data.arg_out{j}), 'vel')
            ang = mot_data.val_out{j};
            
            for k = 2:length(tveco)
                rot(:,k) = ang(:,k)-ang(:,k-1);
            end

            if all(contains(mot_data.arg_out, 'vel') == 0)
                for k = 2:length(tveco)
                    angvel(:,k) = rot(:,k)./(tveco(k)-tveco(k-1));
                end
            end
            continue
        end
        if contains(lower(mot_data.arg_out{j}), 'ang') && contains(lower(mot_data.arg_out{j}), 'vel')
            angvel = mot_data.val_out{j};
                
            if all(contains(mot_data.arg_out, 'rot') == 0) && all(contains(mot_data.arg_out, 'ang') == 0)
                for k = 2:length(tveco)
                    rot(:,k) = angvel(:,k)*(tveco(k)-tveco(k-1));
                    ang(:,k) = ang(:,k-1)+rot(:,k);
                end
            end
            continue
        end
    end

    % Initialize output vectors
    outvec_vel = [vel;angvel]; 
    outvec_dis = [dis;rot];
    outvec_pos = [pos;ang];

    outvec_disvel = [dis;rot;vel;angvel];
    outvec_posvel = [pos;ang;vel;angvel];

    for j = 1:length(mot_data.arg_out)

        if contains(lower(mot_data.arg_out{j}), 'vector') && contains(lower(mot_data.arg_out{j}), 'vel')
            outvec_vel = mot_data.val_out{j};

            vel = outvec_vel(1:length(outvec_vel)/2,:);
            angvel = outvec_vel(length(outvec_vel)/2+1:end,:);
            continue
        end
        if contains(lower(mot_data.arg_out{j}), 'vector') && contains(lower(mot_data.arg_out{j}), 'dis')
            outvec_dis = mot_data.val_out{j};

            dis = outvec_dis(1:length(outvec_dis)/2,:);
            rot = outvec_dis(length(outvec_dis)/2+1:end,:);

            for k = 2:length(tveco)
                pos(:,k) = pos(:,k-1)+dis(:,k);
                ang(:,k) = ang(:,k-1)+rot(:,k);

                vel(:,k) = dis(:,k)./(tveco(k)-tveco(k-1));
                angvel(:,k) = rot(:,k)./(tveco(k)-tveco(k-1));
            end
            continue
        end
        if contains(lower(mot_data.arg_out{j}), 'vector') && contains(lower(mot_data.arg_out{j}), 'pos')
            outvec_pos = mot_data.val_out{j};

            pos = outvec_pos(1:length(outvec_pos)/2,:);
            ang = outvec_pos(length(outvec_pos)/2+1:end,:);

            for k = 2:length(tveco)
                dis(:,k) = pos(:,k)-pos(:,k-1);
                rot(:,k) = ang(:,k)-ang(:,k-1);

                vel(:,k) = dis(:,k)./(tveco(k)-tveco(k-1));
                angvel(:,k) = rot(:,k)./(tveco(k)-tveco(k-1));
            end
            continue
        end
        if contains(lower(mot_data.arg_out{j}), 'vector') && contains(lower(mot_data.arg_out{j}), 'output') && contains(lower(mot_data.arg_out{j}), 'dis') 
            outvec_disvel = mot_data.val_out{j};

            dis    = outvec_disvel(1:length(outvec_disvel)/4,:);
            rot    = outvec_disvel(length(outvec_disvel)/4+1:length(outvec_disvel)/2,:);
            vel    = outvec_disvel(length(outvec_disvel)/2+1:3*length(outvec_disvel)/4,:);
            angvel = outvec_disvel(3*length(outvec_disvel)/4+1:end,:);

            for k = 2:length(tveco)
                pos(:,k) = pos(:,k-1)+dis(:,k);
                ang(:,k) = ang(:,k-1)+rot(:,k);
            end
            continue
        end
        if contains(lower(mot_data.arg_out{j}), 'vector') && contains(lower(mot_data.arg_out{j}), 'output') && contains(lower(mot_data.arg_out{j}), 'pos') 
            outvec_posvel = mot_data.val_out{j};

            pos    = outvec_posvel(1:length(outvec_posvel)/4,:);
            ang    = outvec_posvel(length(outvec_posvel)/4+1:length(outvec_posvel)/2,:);
            vel    = outvec_posvel(length(outvec_posvel)/2+1:3*length(outvec_posvel)/4,:);
            angvel = outvec_posvel(3*length(outvec_posvel)/4+1:end,:);

            for k = 2:length(tveco)
                dis(:,k) = pos(:,k)-pos(:,k-1);
                rot(:,k) = ang(:,k)-ang(:,k-1);
            end
            continue
        end
    end

    % Assign final values
    disf    = dis(:,end);
    posf    = pos(:,end);
    velf    = vel(:,end);
    rotf    = rot(:,end);
    angf    = ang(:,end);
    angvelf = angvel(:,end);

    outvec_velf    = outvec_vel(:,end);
    outvec_disf    = outvec_dis(:,end);
    outvec_posf    = outvec_pos(:,end);
    outvec_disvelf = outvec_disvel(:,end);
    outvec_posvelf = outvec_posvel(:,end);

    % Store all data into induvidual structs
    time_data.t0o   = t0o;
    time_data.tfo   = tfo;
    time_data.dto   = dto;
    time_data.tveco = tveco;

    scalar_data.dis    = dis;
    scalar_data.pos    = pos;
    scalar_data.vel    = vel;
    scalar_data.rot    = rot;
    scalar_data.ang    = ang;
    scalar_data.angvel = angvel;

    scalar_final_data.disf    = disf;
    scalar_final_data.posf    = posf;
    scalar_final_data.velf    = velf;
    scalar_final_data.rotf    = rotf;
    scalar_final_data.angf    = angf;
    scalar_final_data.angvelf = angvelf;

    vector_data.outvec_vel    = outvec_vel;
    vector_data.outvec_dis    = outvec_dis;
    vector_data.outvec_pos    = outvec_pos;
    vector_data.outvec_disvel = outvec_disvel;
    vector_data.outvec_posvel = outvec_posvel;

    vector_final_data.outvec_velf    = outvec_velf;
    vector_final_data.outvec_disf    = outvec_disf;
    vector_final_data.outvec_posf    = outvec_posf;
    vector_final_data.outvec_disvelf = outvec_disvelf;
    vector_final_data.outvec_posvelf = outvec_posvelf;
end
