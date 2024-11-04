
% Create a class handle for python
classdef matlab_adapter < handle

    properties
        nnodes = 1
        dim = 3
        new_step = 0
        old_step = 0
        dt = 1
        acc = []
        dis = []
        pos = []
        vel = []
        tstart = 0
        tfinal = 1
        tvec = zeros(1,1)
        tvec_sim = zeros(1,1)
        init_cond = []
        rhs = []
        M = []
        C = []
        K = []
        dof = 6
        constraint_mat = []
        motion_table = table
        reference_frame_table = table
        solver = "newmark"
        solver_data = 1
        full_filepath = []
    end

    methods

        % Class constructor
        function obj = matlab_adapter(sim_data, varargin)

            % Parse input data 
            p = inputParser;
            p.StructExpand = true;
 
            addOptional(p,'nnodes', sim_data.nnodes);
            addOptional(p,'tstart', sim_data.tstart);
            addOptional(p,'tfinal', sim_data.tfinal);
            addOptional(p,'dt', sim_data.dt);
            addOptional(p,'dim',3);

            parse(p,sim_data);

            obj.nnodes = p.Results.nnodes;
            obj.dim = p.Results.dim;
            obj.dt = p.Results.dt;
            obj.tstart = p.Results.tstart;
            obj.tfinal = p.Results.tfinal;

            obj.tvec = [obj.tstart];
            obj.tvec_sim = obj.tstart:obj.dt:obj.tfinal;            

            % Set constraint matrix
            if isfield(sim_data, 'constraint_mat') == 1 
                obj.constraint_mat = obj.constraint_matrix(sim_data.nnodes, sim_data.dim, sim_data.constraint_mat);
            else
                obj.constraint_mat = obj.constraint_matrix(sim_data.nnodes, sim_data.dim);
            end

            % Set mass, stiffness and damping matrices
            if isfield(sim_data, 'M') == 1 
                obj.M = sim_data.M;
            end
            if isfield(sim_data, 'C') == 1 
                obj.C = sim_data.C;
            end
            if isfield(sim_data, 'K') == 1 
                obj.K = sim_data.K;
            end

            % Set solver details if available
            if isfield(sim_data, 'solver') == 1
                obj.solver = sim_data.solver;
            end
            if isfield(sim_data, 'solver_data') == 1
                obj.solver_data = sim_data.solver_data;
            end

            obj.dof = size(obj.constraint_mat,1); % Set total dofs
            obj.acc(:,1) = zeros(obj.dof, 1); % Create initial acceleration vector
            obj.rhs(:,1) = zeros(obj.dof, 1); % Create initial rhs 

            % Set initial simulation conditions
            if isfield(sim_data, 'init_data') == 1 % Reshape the init_cond into a nx1 array
                obj.init_cond = obj.initialize_data(sim_data.nnodes, sim_data.dim, sim_data.init_data); 
            else
                obj.init_cond = obj.initialize_data(sim_data.nnodes, sim_data.dim);
            end

            obj.dis(:,1) = zeros(obj.dof,1); % Set initial displacements for first time step
            obj.pos(:,1) = obj.init_cond(1:obj.dof,1); % Set initial positions for the first time step
            obj.vel(:,1) = obj.init_cond(obj.dof+1:end,1); % Set initial velocity for first time step

            % Save object as a mat-file in desired location
            disp("matlab_adapter object succesfully created")
            obj.mat_file_loc(varargin{:});
            obj.save_obj(true);
        end

        % Data initialization function to be called by the main simulation function
        function initialize(obj, python_data)

            if obj.tvec(1,end) ~= python_data(end) % Create a time vector
                obj.tvec = [obj.tvec python_data(end)];
                obj.old_step = obj.new_step;
                obj.new_step = obj.new_step+1;
            else
                obj.new_step = obj.old_step+1;
            end
            
            obj.rhs(:,obj.new_step) = python_data(1:end-1)'; % Read load vector for each dof
        end

        % Get file name and save location from varargin
        function mat_file_loc(obj,varargin)

            p = inputParser;

            addOptional(p, 'file_name', "MatAdapterObj.mat", @isstring);
            addOptional(p, 'save_location', pwd, @isstring);
            addOptional(p, 'make_folder', 0, @islogical);

            parse(p,varargin{:});

            file_name = p.Results.file_name;
            save_location = p.Results.save_location;
            make_folder = p.Results.make_folder;
            
            if ~isfolder(save_location) && make_folder
                try
                    mkdir(save_location);
                    disp(append("Folder succesfully created at ",save_location));
                catch
                    disp(append("Folder could not be created at ",save_location));
                    disp(append("New save location is current working folder: ",pwd))
                    save_location = pwd;
                end
            end

            folder    = what(save_location);
            if matches(file_name(end-3:end),".mat")
                file_path = fullfile(folder.path,file_name);
            else
                file_path = fullfile(folder.path,file_name+".mat");
            end

            obj.full_filepath = file_path;
        end

        % Save MAT-file in file location saved in matlab_adapter object
        function save_obj(obj,msg)

            obj_name = inputname(1);

            try
                save(fullfile(obj.full_filepath),obj_name);
                if msg
                    disp(append(obj_name," saved successfully at provided location"));
                end
            catch
                disp(append(obj_name," could not be saved at provided location: ",obj.full_filepath));
                disp(append(obj_name," is now saved in current working folder: ",pwd));
                save(fullfile(pwd,"MatAdapterObj.mat"),obj_name);
            end
        end

        % Function to set motion table
        motion_table = set_motion_table(obj, motionarray)

        % Function to set reference frame table
        reference_frame_table = set_reference_frames(obj, refframes)

        % Function to set prescribed motion values
        set_prescribed_val(obj, file_name, save_location, make_folder)

        % Prescribed motion function
        prescribed_motion(obj, port_file)

        % Coupled simulation function
        coupled_simulation(obj, port_file)

    end

    methods (Static)
        
        % Function to create desired input data
        function init_cond = initialize_data(nnodes, dim, init_data)

            init_cond = zeros(dim*nnodes*4,1); % Create array to save input data

            if nargin > 2
                for i = 1:nnodes % Save initial positions
                    if ismember('position', lower(fieldnames(init_data)))
                        init_cond((i-1)*dim*2+1:(i-1)*dim*2+dim) = init_data.Position(i,:)';
                    end
                    if ismember('rotation', lower(fieldnames(init_data)))
                        init_cond((i-1)*dim*2+dim+1:i*dim*2) = init_data.Rotation(i,:)';
                    end
                end
    
                for i = 1:nnodes % Save initial velocities
                    if ismember('velocity', lower(fieldnames(init_data)))
                        init_cond((i-1+nnodes)*dim*2+1:(i-1+nnodes)*dim*2+dim) = init_data.Velocity(i,:)';
                    end
                    if ismember('angularvelocity', lower(fieldnames(init_data)))
                        init_cond((i-1+nnodes)*dim*2+dim+1:(i+nnodes)*dim*2) = init_data.AngularVelocity(i,:)';
                    end
                end
            end
        end

        % Function to create constraint matrix
        function constraint_mat = constraint_matrix(nnodes, dim, input_constraint_matrix)

            if nargin > 2
                if size(input_constraint_matrix,1) >= nnodes*dim*2 % Check if geoW object is available
                    constraint_mat = input_constraint_matrix(1:nnodes*dim*2,:);
                else
                constraint_mat = input_constraint_matrix; % Use user's constraint matrix
                end
            else
                constraint_mat = eye(nnodes*dim*2); % Create a default constraint matrix
            end
        end
    
    end
end
