clearvars;clc;

%% Simulation setup

% Basic configuration data
sim_data.nnodes = 13; 
sim_data.dim = 3;
sim_data.dt = 0.001;
sim_data.tstart = 0;
sim_data.tfinal = 2;

%% Create a matlab_adapter object

% Save location and file name details
save_location = "../../Output/matlab/";
file_name = "wing_propeller";
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

refframe2.is_prop = 0;
refframe2.parent_tag = 7;
refframe2.ref_tag = "PivotPoint";
refframe2.origin = [ 0   0  -0.2 ];
refframe2.orientation = [ -1   0   0  ; ...
                           0   1   0  ; ...
                           0   0  -1  ];

refframe3.is_prop = 0;
refframe3.parent_tag = "PivotPoint";
refframe3.ref_tag = "Hub";
refframe3.origin = [ 1.2  0   0 ];
refframe3.orientation = [  1   0   0  ; ...
                           0   1   0  ; ...
                           0   0   1  ];

refframe4.is_prop = 0;
refframe4.parent_tag = "Hub";
refframe4.ref_tag = "Rot";
refframe4.origin = [ 0   0   0 ];
refframe4.orientation = [  1   0   0  ; ...
                           0   1   0  ; ...
                           0   0   1  ];

refframe5.is_prop = 1;
refframe5.num_blades = 4;
refframe5.node_incl = [10 11 12 13];
refframe5.parent_tag = "Rot";
refframe5.ref_tag = "Prop";
refframe5.origin = [ 0   0   0 ];

%% Set reference frame table

refframe_array = {refframe1,refframe2,refframe3,refframe4,refframe5};

reference_frame_table = matAdapterObj.set_reference_frames(refframe_array);

%% Set data for prescribed motion

motdata1.mot_mode = "r";
motdata1.mot_axis = [ 0   1   0 ];
motdata1.mot_type = "h";
motdata1.ref_frame = "Wing";
motdata1.t0 = 0;
motdata1.tf = 2;
motdata1.amp = pi/18; % 10°
motdata1.omega = 20*pi;

motdata2.mot_mode = "r";
motdata2.mot_axis = [ 1   0   0 ];
motdata2.mot_type = "c";
motdata2.ref_frame = "Rot";
motdata2.t0 = 0;
motdata2.tf = 2;
motdata2.rate = 250*pi/3; % 2500 rpm

motdata3.mot_mode = "r";
motdata3.mot_axis = [ 0   0   1 ];
motdata3.mot_type = "h";
motdata3.ref_frame = "PivotPoint";
motdata3.t0 = 0;
motdata3.tf = 2;
motdata3.amp = pi/36; % 5°
motdata3.omega = 40*pi;

% load("golandWing.mat"); % Contains the eigenvalues and eigenvectors of the goland wing
% 
% motdata4.mot_mode = "e";
% motdata4.mot_axis = [ 0   0   0 ]; % Optional input
% motdata4.mot_type = ""; % Optional input
% motdata4.ref_frame = "Wing";
% motdata4.t0 = 0;
% motdata4.tf = 2;
% motdata4.freq = 250; % Hz
% motdata4.eigval = golandWing.eigenvalue;
% motdata4.eigvec = golandWing.eigenvector;
% motdata4.mode = 1; % First mode shape
% motdata4.damp = 0;

% load("orientationvector_pivotpoint.mat");
% 
% motdata5.mot_mode = "r";
% motdata5.mot_axis = [ 0   0   0 ];
% motdata5.mot_type = "u";
% motdata5.ref_frame = "PivotPoint";
% motdata5.vec = orientationvector_pivotpoint; % Contains an orientation vector of the pivoting point with motions about local y and z axes
% motdata5.vec_loc = 'f';
% motdata5.vec_type = 'p';
% motdata5.t0 = 0;
% motdata5.tf = 2;

% load("mode_shapes_wing.mat"); % Contains the positions and orientations of the nodes for different mode shapes over a period of 2 secs and freq=1000 Hz
% 
% motdata6.mot_mode = "u";
% motdata6.mot_axis = [ 0   0   0 ];
% motdata6.mot_type = "";
% motdata6.ref_frame = "Wing";
% motdata6.vec = mode_shape_1; % 1st mode shape: motion vectors for all nodes(6 dof each)
% motdata6.vec_loc = 'n';
% motdata6.vec_type = 'p';
% motdata6.t0 = 0;
% motdata6.tf = 2;

%% Set motion table

motionarray = {motdata1,motdata2,motdata3};

motion_table = matAdapterObj.set_motion_table(motionarray);

%% Setup prescribed values

matAdapterObj.set_prescribed_val();

%% Call matlab_adapter function

% Text file containing port number
port_file = "port.txt"; % Optional

% Coupling function
matAdapterObj.prescribed_motion(port_file);
