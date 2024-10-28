% Prescribed motion function
function prescribed_motion(obj, varargin)

    % Use default text file if not provided
    if nargin > 1
        port_file = varargin{1};
    else
        port_file = "port.txt";
    end

    % Read text file containing port number
    fid = fopen(port_file, "r");
    port = fscanf(fid, '%d');
    fclose(fid);

    % Create connection between python and matlab
    client = tcpclient('localhost', port, 'ConnectTimeout', 5); 

    disp(newline + "//////////////////////////////////////////");
    disp(newline + "  Beginning prescribed motion simulation" + newline)
    disp("//////////////////////////////////////////");
    disp(newline + "Connected to '" + client.Address + "' , " + client.Port + newline);

    % Write initial conditions to the precice object in python adapter
    try 
        disp("Writing initial data to python-precice")
        % write(client, sprintf('%14e;', obj.init_cond));
        write(client, sprintf('%14e;', [obj.pos(:,1);obj.vel(:,1)]));
        disp("Initial data written successfully" + newline);
    catch
        clear("client");
        disp("Could not write initial data to python-precice" + newline + "Exiting ......" + newline);
        return
    end

    obj.old_step = 0;
    obj.new_step = 0;
    obj.rhs = obj.rhs(:,1);

    while true % Begin solver 
        tic;
        if exist('time_start', 'var') == 0
            time_start = tic;
        end

        if client.NumBytesAvailable > 0 % Read data from python
            bytes = read(client);
            python_str = char(bytes(1:end));
            python_data = str2num(python_str);

            if python_data(end) > obj.tfinal % Terminate simulation
                break
            else
                obj.initialize(python_data); % Initialize data
            end

            obj.save_obj(false); % Save object with updated rhs values to given save location
 
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
            if toc(time_start) > 60 % Idle time set to 60 as default. Can be changed or replaced with a user input based on system computational capabilities.
                obj.save_obj(true);
                toc(time_start);
                disp("Server timeout/disconnected");
                clear("client");
                break
            end
        end
    end
    return
end