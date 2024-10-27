%% Create matlab_adapter Object(+ Simulation Data)
%
% Basic parameters of the simulation are saved into a structure and passed into the matlab_adapter object:
%    matAdapterObj = matlab_adapter(sim_data, file_name, save_location, make_folder);
% OR matAdapterObj = matlab_adapter(sim_data);
%
% To save the matlab_adapter object into a MAT-file we can provide optional parameters such as: 
% 1. file_name -> name of the MAT-file: [default: "MatlabAdapterObject"]
%                 string input
% 2. save_location -> directory/folder in which the MAT-file should be saved: [default: current working directory/folder].
%                     string input
% 3. make_folder -> flag to create a folder if it does not already exist: [default: false]
%                   logical input
%
% Note: The matlab_adapter object has methods to create an absolute path from the save_location and file_name. This absolute path is stored in the matlab_adpater object and used by other methods to save and update the matlab_adapter object's properties.
%
% The simulation data structure has the following fields:
% 
% Mandatory fields:
% 1. nnodes -> defines the total number of nodes in the simulation:
%              numerical input - must be same as the number of coupling nodes used by DUST.
% 2. dim -> defines the total number of dimensions in the simulation [default: 3]
%           numerical input
% 3. dt -> defines the incremental time step of the simulation:
%          numerical input - units: s
% 4. tstart -> defines the starting time of the simulation: [default: 0]
%              numerical input -  units: s
% 5. tfinal -> defines the starting time of the simulation: [default: 1]
%              numerical input -  units: s
%
%% Set Reference Frames
%
% Each reference frame is considered to be an induvidual space with its own nodes, orientation and origin:
% 
% Each reference frame is passed into the 'set_reference_frame' function as a cell array of structures:
%    reference_frame_table = matAdapterObj.set_reference_frames(refframes_array);
% 
% Note: The reference_frame_table is saved into the matlab_adapter object and the updated matlab_adapter object is saved at given file_name and save_location.
%
% Every reference frame structure has the following input fields:
% 
% Standard Fields:
% 1. ref_tag -> defines the name/tag given to the reference frame: [default: 'Prop' IF is_prop is true, None IF is_prop is false]
%               string input - must be a valid string and not be 0 or a positive integer between 1 and sim_data.nnodes; additional information added to ref_tag IF is_prop is true (ref_tag = ref_tag+'0'+propeller_number+'_0'+blade_number).
% 2. parent_tag -> defines the tag of the parent reference frame: [default: 0]
%                  string input - must be an existing reference frame's ref_tag.
%                  numerical input - can be 0 which represents the global reference frame or a positive integer between 1 and sim_data.nnodes already defined in an existing reference frame.
% 3. origin -> defines the local origin in the parent reference frame's orientation: [default: [ 0  0  0 ]]
%              numerical input - size: 1x3 numerical array.
% 4. orientation -> defines the local orientation w.r.t the parent reference frame's orientation, i.e. parent->local: [default: [ 1  0  0
%                                                                                                                                 0  1  0
%                                                                                                                                 0  0  1 ]]
%                   numerical input - size: 3x3 numerical array; must have a magnitude of 1.
% 5. node_incl -> defines the nodes to be included in the reference frame: [default: []]
%                 numerical input - size: 1xN numerical array; must contain positive integers between 1 and sim_data.nnodes; each node must be defined only(and atleast) once across all reference frames.
% 6. node_pos -> defines the position of the nodes in the local reference frame w.r.t the reference frame's origin [default: []]
%                numerical input - size: 3xlength(node_incl)
% 7. is_prop -> defines whether the reference frame consists of propeller wings: [default: false]
%               logical input - IF is_prop is 'true', the reference frame must be attached to another reference frame which defines the motion of the propeller blades.
% 8. num_blades -> defines the number of blades in the reference frame: [default: []]
%                  numerical input - size: 1xlength(node_incl)
%
% The output of the set_reference_frame function is a reference frame table with the following fields:
%  1. ref_tag
%  2. parent_tag
%  3. origin
%  4. orientation -> IF is_prop is 'True', the first blade is defined in the direction of the negative z-axis of the parent reference frame.
%  5. node_incl
%  6. is_prop
%  7. origin_global -> co-ordinates of the reference frame's origin w.r.t global reference frame's origin.
%  8. orientation_global -> orientation of the reference frame w.r.t the global reference frame's orientation.
%  9. node_pos
% 10. num_blades
%
%% Set Prescribed Values(+ Motion Table)
%
% Each node has 6 degrees of freedom(3 translatory + 3 rotatory) and motion about each dof in the global reference frame is calculated before the coupled simulation begins:
% 
% Each prescribed motion is passed into the function as a cell array of structures and saved as a table:
%    motion_table = matAdapterObj.set_motion_table(motionarray);
%
% Note: The motion_table is saved into the matlab_adapter object and the updated matlab_adapter object is saved at given file_name and save_location.
% 
% Each motion structure has the following input fields:
% 
% Standard inputs:
% 1. ref_frame -> defines the reference frame which will undergo the prescribed motion: [default: "0"]
%                 string input -> must be a valid ref_tag of an existing reference frame.
% 2. mot_mode -> defines the overall motion: [default: ""]
%                string input - available options: 'l'- linear, 'r'- rotation, 'e'- eigenmotion, 'f'- custom function, 'u'- user input.
% 3. mot_type -> defines the type of prescribed motion: [default: ""]
%                string input - available options: 'c'- constant, 'h'- harmonic, 'f'- custom function(1-dof), 'u'- user input(1-dof); will be ignored for eigenmotion('e'), custom function('f') and user input motion('u') modes.
% 4. mot_axis -> defines the axis of the prescribed motion in the parent reference frame: [default: [0 0 0]]
%                numerical input - size: 1x3; will be ignored for eigenmotion('e'), custom function('f') and user input motion('u') modes.
% 
% Optional inputs:
% 1. t0 -> starting time of prescribed motion: [default: sim_data.tstart]
%          numerical input - 0 <= sim_data.tstart <= t0 <= tf <= sim_data.tfinal
% 2. tf -> ending time of prescribed motion: [default: sim_data.tfinal]
%          numerical input - 0 <= sim_data.tstart <= t0 <= tf <= sim_data.tfinal
% 
% Mode-dependent inputs:
% 
% a. Linear('l') mode:
% 1. amp -> defines the amplitude of prescribed motion: [default: 0]
%           numerical input - units: m
%           available for harmonic('h') type motion.
% 2. omega -> defines the angular frequency of prescribed motion: [default: 0]
%             numerical input - units: rad/s
%             available for harmonic('h') type motion.
% 3. phi -> defines the initial phase offset for prescribed motion: [default: 0]
%           numerical input - units: rad
%           available for harmonic('h') type motion.
% 4. offset -> defines the constant offset of prescribed motion: [default: 0]
%              numerical input - units: m
%              available for harmonic('h') type motion.
% 5. lambda -> defines the decay rate of prescribed motion: [default: 0]
%              numerical input - units: 1/s
%              available for constant('c') and harmonic('h') type motions.
% 6. rate -> defines the motion rate: [default: 0]
%            numerical input - units: m/s
%            available for constant('c') type motion.
% 
% b. Rotation('r') mode:
% 1. amp -> defines the amplitude of prescribed motion: [default: 0]
%           numerical input - units: rad
%           available for harmonic('h') type motions.
% 2. omega -> defines the angular frequency of prescribed motion: [default: 0]
%             numerical input - units: rad/s
%             available for harmonic('h') type motion.
% 3. phi -> defines the initial phase offset for prescribed motion: [default: 0]
%           numerical input - units: rad
%           available for harmonic('h') type motion.
% 4. offset -> defines the constant offset of prescribed motion: [default: 0]
%              numerical input - units: rad
%              available for harmonic('h') type motion.
% 5. lambda -> defines the decay rate of prescribed motion: [default: 0]
%              numerical input - units: 1/s
%              available for constant('c') and harmonic('h') type motions.
% 6. rate -> defines the motion rate: [default: 0]
%            numerical input - units: rad/s
%            available for constant('c') type motion.
% 
% c. Eigenmotion('e') mode:
% 1. freq -> defines the sampling frequency for the eigenmotion: [default: 0]
%            numerical input - units: 1/s
% 2. eigval -> defines the eigenvalues of the eigenmotion: [default: 0]
%              numerical input - size: Nx1 complex double array.
% 3. eigvec -> defines the eigenvectors of the eigenmotion: [default: 0]
%              numerical input - size: (6*length(node_incl))xN numerical array.
% 4. mode -> defines the mode shape of the eigenmotion: [default: 1]
%            numerical input
% 5. damp -> defines whether the motion is damped or undamped: [default: false]
%            logical input
% 
% d. Custom function('f') mode/type:
% 1. arg_in -> defines the name and order of the input arguments of the custom function: [default: {}] 
%              cell input - size 1x1 cell array; can contain predefined user inputs(eg: constants)
% 2. val_in -> defines the values of the input arguments of the custom function: [default: {}]
%              cell input - size: 1x1 cell array; can contain predefined user inputs(eg: constants); must be in the same order as arg_in.
% 3. arg_out -> defines the name and order of the output arguments of the custom function: [default: {}]
%               cell input - size 1x1 cell array;
% 4. val_out -> defines the values of the output arguments of the custom function: [default: {}]
%               cell input - size: 1x1 cell array; can contain user-defined variables which will be filled in the same order as arg_out.
% 5. func -> defines the function handle of the custom function: [default: []]
%            function handle input - must point to a function in MATLAB path/current working directory.
% 
% e. User defined motion('u') mode/type:
% 1. vec_loc -> defines the location of the input vector:
%               string input - available options: 'n'- nodal values, 'f'- reference frame origin values.
% 2. vec -> defines the input vector for the user-defined motion:
%           numerical input - size: 3x(length(matAdapterObj.tvec_sim)) IF mot_type is 'u' AND vec_loc is 'f',
%                             size: (3*sim_data.nnodes)x(length(matAdapterObj.tvec_sim)) IF mot_type is 'u' AND vec_loc is 'n',
%                             size: 6x(length(matAdapterObj.tvec_sim)) IF mot_mode is 'u' AND vec_loc is 'f',
%                             size: (6*sim_data.nnodes)x(length(matAdapterObj.tvec_sim)) IF mot_mode is 'u' AND vec_loc is 'n'
% 3. vec_type -> defines the type of input vector:
%                string input - available options: 'd'- displacement input vector, 'p'- position input vector, 'v'- velocity input vector.
%
% The output of the set_motion_table function is a table with the following fields:
% 1. ref_frame
% 2. mot_mode
% 3. mot_type
% 4. mot_axis
% 5. mot_data -> struct containing all data for motion calculation.
%
% The prescribed motion calculation function which is a function of the matlab_adapter object is called as follows:
%    matAdapterObj.set_prescribed_val();
% 
% The outputs of this function are:
% 1. pos -> global positions of each node in all 6 dofs after each time step [passed back to the MATLAB-preCICE (python)adapter]:
%           numerical output - size: (6*sim_data.nnodes)x(length(matAdapterObj.tvec_sim)); saved in matAdapterObj.
% 2. vel -> global velocities of each node in all 6 dofs in each time step [passed back to the MATLAB-preCICE (python)adapter]:
%           numerical output - size: (6*sim_data.nnodes)x(length(matAdapterObj.tvec_sim)); saved in matAdapterObj.
% 3. dis -> global displacements of each node in all 6 dofs in each time step:
%           numerical output - size: (6*sim_data.nnodes)x(length(matAdapterObj.tvec_sim)); saved in matAdapterObj.
% 4. acc -> global accelerations of each node in all 6 dofs in each time step:
%           numerical output - size: (6*sim_data.nnodes)x(length(matAdapterObj.tvec_sim)); saved in matAdapterObj.
% 5. position_global -> global position of each reference frame in each time step:
%                       numerical output - size: (sim_data.dim)x(length(matAdapterObj.tvec_sim)); saved in matAdapterObj.reference_frame_table.
% 6. orientationmatrix_global -> global orientation of each reference frame in each time step:
%                                numerical output - size: (sim_data.dim)x(sim_data.dim)x(length(matAdapterObj.tvec_sim)); saved in matAdapterObj.reference_frame_table.
%
%% Coupled Simulation(using Prescribed Values) with DUST
%
% Once the prescribed values have been set, the python script "main.py" can be started:
% port_file = "port.txt" - This is the default text file created in the 'matlab' folder provided by the user in the "main.py" script; Optional input.
%
% The prescribed motion function which is a function of the matlabAdapterObject can be called with the port_file as the input argument:
%    matAdapterObj.prescribed_motion(port_file); [default: port_file = "port.txt"]
% OR matAdapterObj.prescribed_motion();
%
% Note: If port_file is provided as an absolute path to the "port.txt" text file created by the preCICE-MATLAB adapter, the prescribed_motion function can be run from any folder.
% 
% The outputs of this function are:
% 1. rhs -> forces calculated about each dof for all nodes by DUST:
%           numerical output - size: (6*sim_data.nnodes)x1; appended to matAdapterObj.rhs after each time step.
% 2. tstep -> current time step in DUST and preCICE:
%           numerical output - size: 1x1; appended to matAdapterObj.tvec after each time step.
%
% Note: Add the matlab_solver file to the MATLAB path. 
% Note: The preCICE-MATLAB adapter file must be added to the system path in the "main.py" script.
%
%% matlab_adapter Object Example: 
%
% sim_data.nnodes = 13; 
% sim_data.dim = 3;
% sim_data.dt = 0.001;
% sim_data.tstart = 0;
% sim_data.tfinal = 2;
%
% file_name = "wing_propeller";
% save_location = "../../Output/matlab/";
% make_folder = true;
% 
% matAdapterObj = matlab_adapter(sim_data, file_name, save_location, make_folder);
%
%% Reference Frames Setup Example:
%
% refframe_array{1}.is_prop = 0;
% refframe_array{1}.parent_tag = 0;
% refframe_array{1}.ref_tag = "Wing";
% refframe_array{1}.origin = [ 0   0   0 ];
% refframe_array{1}.orientation = [  1   0   0  ; ...
%                                    0   1   0  ; ...
%                                    0   0   1  ];
% refframe_array{1}.node_incl = [1 2 3 4 5 6 7 8 9];
% refframe_array{1}.node_pos = [  0     0     0  ; ...
%                         0   0.762   0  ; ...
%                         0   1.524   0  ; ...
%                         0   2.286   0  ; ...
%                         0   3.048   0  ; ...
%                         0   3.810   0  ; ...
%                         0   4.572   0  ; ...
%                         0   5.334   0  ; ...
%                         0   6.096   0  ];
% 
% refframe_array{2}.is_prop = 0;
% refframe_array{2}.parent_tag = 7;
% refframe_array{2}.ref_tag = "PivotPoint";
% refframe_array{2}.origin = [ 0   0  -0.2 ];
% refframe_array{2}.orientation = [  1   0   0  ; ...
%                                    0   1   0  ; ...
%                                    0   0   1  ];
% 
% refframe_array{3}.is_prop = 0;
% refframe_array{3}.parent_tag = "PivotPoint";
% refframe_array{3}.ref_tag = "Hub";
% refframe_array{3}.origin = [ 1.2  0   0 ];
% refframe_array{3}.orientation = [ -1   0   0  ; ...
%                                    0  -1   0  ; ...
%                                    0   0   1  ];
% 
% refframe_array{4}.is_prop = 0;
% refframe_array{4}.parent_tag = "Hub";
% refframe_array{4}.ref_tag = "Rot";
% refframe_array{4}.origin = [ 0   0   0 ];
% refframe_array{4}.orientation = [  1   0   0  ; ...
%                                    0   1   0  ; ...
%                                    0   0   1  ];
% 
% refframe_array{5}.is_prop = 1;
% refframe_array{5}.num_blades = 4;
% refframe_array{5}.node_incl = [10 11 12 13];
% refframe_array{5}.parent_tag = "Rot";
% refframe_array{5}.ref_tag = "Prop";
% refframe_array{5}.origin = [ 0   0   0 ];
% 
% reference_frame_table = matAdapterObj.set_reference_frames(refframe_array);
%
%% Motion Table Setup + Prescribed Motion Calculation Example:
% 
% motionarray{1}.mot_mode = "e";
% motionarray{1}.mot_axis = [ 0   0   0 ];
% motionarray{1}.mot_type = "";
% motionarray{1}.ref_frame = "Wing";
% motionarray{1}.t0 = 0;
% motionarray{1}.tf = 2;
%
% load("Wing.mat"); % Contains the eigenvalues and eigenvectors of the wing
% motionarray{1}.freq = 250;
% motionarray{1}.eigval = Wing.eigenvalue;
% motionarray{1}.eigvec = Wing.eigenvector;
% motionarray{1}.mode = 1;
% motionarray{1}.damp = 0;
%
%
% motionarray{2}.mot_mode = "u";
% motionarray{2}.mot_axis = [ 0   0   0 ];
% motionarray{2}.mot_type = "";
% motionarray{2}.ref_frame = "PivotPoint";
% motionarray{2}.t0 = 0.5;
% motionarray{2}.tf = 1.5;
%
% load("PivotPoint.mat") % Contains time-varied offset+orientation vector of the pivoting point(6 dof)
% motionarray{2}.vec_loc = "f";
% motionarray{2}.vec = PivotPoint.User_Defined_Motion;
% motionarray{2}.vec_type = "p";
% 
%
% motionarray{3}.mot_mode = "r";
% motionarray{3}.mot_axis = [ 1   0   0 ];
% motionarray{3}.mot_type = "c";
% motionarray{3}.ref_frame = "Rot";
% motionarray{3}.t0 = 0;
% motionarray{3}.tf = 2;
% motionarray{3}.rate = 2*pi*2500/60;
% 
%
% motion_table = matAdapterObj.set_motion_table(motionarray);
%
%
% matAdapterObj.set_prescribed_val();
%
%% Prescribed Motion+DUST Coupling Function Call Example:
%
% port_file = "./port.txt";
% 
% matAdapterObj.prescribed_motion(port_file);
%