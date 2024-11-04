clearvars;clc;

%% Simulation setup

% Basic configuration data
sim_data.nnodes = 9; 
sim_data.dim = 3;
sim_data.dt = 0.001;
sim_data.tstart = 0;
sim_data.tfinal = 2;

%% Create a matlab_adapter object

% Save location and file name details
save_location = "./../dust/Postpro";
file_name = "golandwing_sim";
make_folder = false;

% Create matlab_adapter object
matAdapterObj = matlab_adapter(sim_data, file_name, save_location, make_folder);

%% Set data for reference frame

refframe1.is_prop = 0;
refframe1.parent_tag = 0;
refframe1.ref_tag = "Wing";
refframe1.origin = [ 0   0   0 ];
refframe1.orientation = [  1   0   0  ; ...
                           0   1   0  ; ...
                           0   0   1  ];
refframe1.node_incl = [1 2 3 4 5 6 7 8 9];
refframe1.node_pos = [  0     0     0  ; ...
                        0   0.762   0  ; ...
                        0   1.524   0  ; ...
                        0   2.286   0  ; ...
                        0   3.048   0  ; ...
                        0   3.810   0  ; ...
                        0   4.572   0  ; ...
                        0   5.334   0  ; ...
                        0   6.096   0  ];


%% Set reference frame table

reference_frame_table = matAdapterObj.set_reference_frames({refframe1});

%% Set data for prescribed motion

motdata1.mot_mode = "r";
motdata1.mot_axis = [ 0   1   0 ];
motdata1.mot_type = "h";
motdata1.ref_frame = "Wing";
motdata1.t0 = 0;
motdata1.tf = 2;
motdata1.amp = pi/18; % 10°
motdata1.omega = 20*pi;


% load("golandWing.mat"); % Contains the eigenvalues and eigenvectors of the goland wing
% 
% motdata2.mot_mode = "e";
% motdata2.mot_axis = [ 0   0   0 ]; % Optional input
% motdata2.mot_type = ""; % Optional input
% motdata2.ref_frame = "Wing";
% motdata2.t0 = 0;
% motdata2.tf = 2;
% motdata2.freq = 1/sim_data.dt; % Hz
% motdata2.eigval = golandWing.eigenvalue;
% motdata2.eigvec = golandWing.eigenvector./5;
% motdata2.mode = 1; % 1st mode shape
% motdata2.damp = 0;

% load("mode_shapes_wing.mat"); % Contains the positions and orientations of the nodes for different mode shapes over a period of 2 secs and freq=1000 Hz
% 
% motdata3.mot_mode = "u";
% motdata3.mot_axis = [ 0   0   0 ];
% motdata3.mot_type = "";
% motdata3.ref_frame = "Wing";
% motdata3.vec = mode_shape_1; % 1st mode shape: motion vectors for all nodes(6 dof each)
% motdata3.vec_loc = 'n';
% motdata3.vec_type = 'p';
% motdata3.t0 = 0;
% motdata3.tf = 2;

% load("refframe_motions_wing.mat"); % Contains various time-varied motion vectors that can be applied to the nodes or the reference frame of the wing
% 
% motdata4.mot_mode = "u";
% motdata4.mot_axis = [ 0   0   0 ];
% motdata4.mot_type = "";
% motdata4.ref_frame = "Wing";
% motdata4.vec = pitch_plunge; % Combined pitch and plunge motion applied to the wing reference frame(origin)
% motdata4.vec_loc = 'f';
% motdata4.vec_type = 'p';
% motdata4.t0 = 0;
% motdata4.tf = 2;

% load("refframe_motions_wing.mat");
% 
% motdata5.mot_mode = "l";
% motdata5.mot_axis = [ 0   0   0 ]; % If mot_axis is [0 0 0], vec must be an orientation vector, else vec can be a time-varied scalar data (vec.*axis = orientation vector)
% motdata5.mot_type = "u";
% motdata5.ref_frame = "Wing";
% motdata5.vec = plunge; % Plunge motion applied to the reference frame(translational dofs only)
% motdata5.vec_loc = 'f';
% motdata5.vec_type = 'p';
% motdata5.t0 = 0;
% motdata5.tf = 2;

%% Set motion table

motion_table = matAdapterObj.set_motion_table({motdata1});

%% Setup prescribed values

matAdapterObj.set_prescribed_val();

%% Call matlab_adapter function

% Text file containing port number
port_file = "port.txt"; % If port_file is provided as an absolute path, the prescribed_motion function can be run from anywhere

% Coupling function
matAdapterObj.prescribed_motion(port_file);
