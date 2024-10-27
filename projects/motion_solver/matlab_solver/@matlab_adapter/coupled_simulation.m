% Create a function for coupled simulation
function coupled_simulation(obj, varargin)
    
    if nargin > 1 % Use default text file if not provided
        port_file = varargin{1};
    else
        port_file = "port.txt";
    end

    fid = fopen(port_file, "r"); % Read text file containing port number
    port = fscanf(fid, '%d');
    fclose(fid);

    client = tcpclient('localhost', port, 'ConnectTimeout', 5); % Create connection between python and matlab

    disp(newline + "//////////////////////////////////////////");
    disp(newline + "      Beginning coupled simulation" + newline);
    disp("//////////////////////////////////////////");
    disp(newline + "Connected to '" + client.Address + "' , " + client.Port + newline);

    try % Write initial conditions to the precice object in python adapter
        disp("Writing initial data to python-precice");
        write(client, sprintf('%14e;', obj.init_cond));
        disp("Initial data written successfully" + newline);
    catch
        clear("client");
        disp("Could not write initial data to python-precice" + newline + "Exiting ......" + newline);
        return
    end

    while true % Begin solver 
        tic;
        if exist('time_start', 'var') == 0
            time_start = tic;
        end
            if client.NumBytesAvailable > 0 % Read data from python
                bytes = read(client);
                python_str = char(bytes(1:end));
                python_data = str2num(python_str);
    
                obj.initialize(python_data); % Initialize data
        
                % Use desired solver function for the current time_step
                if length(obj.tvec) == 1 % Set time step
                    dT = obj.dt;
                else
                    dT = obj.tvec(end)-obj.tvec(end-1);
                end

                rhs = obj.constraint_mat'*obj.rhs(:,obj.new_step); % Set rhs for current time step

                if length(obj.tvec) == 1 % Set initial acceleration, velocity and displacement for new time step
                    an = obj.constraint_mat'*obj.acc(:,1); 
                    xn = obj.constraint_mat'*(obj.pos(:,1)-obj.init_cond(1:obj.dof,1));
                    vn = obj.constraint_mat'*obj.vel(:,1);
                else
                    an = obj.constraint_mat'*obj.acc(:,obj.old_step); 
                    xn = obj.constraint_mat'*(obj.pos(:,obj.old_step)-obj.init_cond(1:obj.dof,1));
                    vn = obj.constraint_mat'*obj.vel(:,obj.old_step);
                end

                switch erase(erase(lower(obj.solver),' '),'-')

                    case {'newmark', 'newmarkbeta'} % Newmark-beta method
                        [an1, vn1, xn1] = newmark_solver(dT, rhs, an, vn, xn, obj.M, obj.C, obj.K, obj.solver_data);

                    case {'generalizedalpha', 'genalpha'} % Generalized alpha method
                        [an1, vn1, xn1] = genalpha_solver(dT, rhs, an, vn, xn, obj.M, obj.C, obj.K, obj.solver_data); 
                        
                    % case {'generalizedalpha3', 'genalpha3'} % Third order generalized alpha method
                    %     [an1, vn1, xn1] = genalpha3_solver(dT, rhs, an, vn, xn, obj.M, obj.C, obj.K, obj.solver_data); 
                    % 
                    % case {'ode45', 'ode23s'} % MATLAB built-in ode solvers
                    %     [an1, vn1, xn1] = ode_solver(dT, rhs, vn, xn, obj.M, obj.C, obj.K, obj.solver);
                    % 
                    % case {'erk4', 'explicitrungekutta4'} % Runge-Kutta 4th order solver
                    %     [an1, vn1, xn1] = erk4_solver(dT, rhs, vn, xn, obj.M, obj.C, obj.K);
                    % 
                    % case {'erk45', 'explicitrungekutta45', 'rungekuttafehlberg'} % Runge-Kutta 4th order 5-step solver
                    %     [an1, vn1, xn1] = erk45_solver(dT, rhs, vn, xn, obj.M, obj.C, obj.K, obj.solver_data);
                    % 
                    % case {'bdf', 'backwarddifferenceformula'} % Backwards difference formula
                    %     x = [];
                    %     v = [];
                    %     order = 2;
                    %     if obj.old_step < order
                    %         ord = obj.old_step;
                    %     else
                    %         ord = order;
                    %     end
                    %     for i = 1:ord
                    %         x = [x obj.constraint_mat'*obj.dis(:,obj.old_step-ord+i)];
                    %         v = [v obj.constraint_mat'*obj.vel(:,obj.old_step-ord+i)];
                    %     end
                    %     [an1, vn1, xn1] = bdf_solver(dT, rhs, v, x, obj.M, obj.C, obj.K, ord);
                end
                                   
                obj.acc(:,obj.new_step) = obj.constraint_mat*an1; % Save new acceleration, velocity and displacement to be used in new time step
                obj.vel(:,obj.new_step) = obj.constraint_mat*vn1;
                obj.pos(:,obj.new_step) = obj.constraint_mat*xn1+obj.init_cond(1:obj.dof,1);
                if length(obj.tvec) == 1
                    obj.dis(:,obj.new_step) = obj.pos(:,obj.new_step)-obj.init_cond(1:obj.dof,1);
                else
                    obj.dis(:,obj.new_step) = obj.pos(:,obj.new_step)-obj.pos(:,obj.old_step);
                end

                new_cond = [obj.pos(:,obj.new_step);obj.vel(:,obj.new_step)]; % Save final data

                try      
                    write(client, sprintf('%14e;', new_cond)); % Write to python
                    disp("------------------------------------------");
                    disp("Total Bytes sent: " + client.NumBytesWritten);
                    disp("Latest time step: " + obj.tvec(end));
                    toc;
                    disp("------------------------------------------");
                    disp("//////////////////////////////////////////");
                    time_start = tic;

                catch 
                    clear("client"); % Clear server and exit matlab
                    toc;
                    break
                end

           else % Check for timeout
                if toc(time_start) > 10
                    toc(time_start);
                    disp("Server timeout/disconnected" + newline);
                    clear("client");
                    break
                end
           end
    end
    return
end