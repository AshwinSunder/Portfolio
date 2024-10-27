clearvars;clc;

%% Simulation setup

% Basic configuration data
sim_data.nnodes = 4; 
sim_data.dim = 3;
sim_data.dt = 0.001;
sim_data.tstart = 0;
sim_data.tfinal = 2;

%% Create a matlab_adapter object

% Save location and file name details
save_location = "../../Output/matlab/";
file_name = "propeller";
make_folder = false;

% Create matlab_adapter object
matAdapterObj = matlab_adapter(sim_data, file_name, save_location, make_folder);

%% Set data for reference frame

refframe1.is_prop = 0;
refframe1.parent_tag = 0;
refframe1.ref_tag = "PivotPoint";
refframe1.origin = [ 0   0   0 ];
refframe1.orientation = [  1   0   0  ; ...
                           0   1   0  ; ...
                           0   0   1  ];

refframe2.is_prop = 0;
refframe2.parent_tag = "PivotPoint";
refframe2.ref_tag = "Hub";
refframe2.origin = [ -0.6  0   0 ];
refframe2.orientation = [ -1   0   0  ; ...
                           0   1   0  ; ...
                           0   0  -1  ];

refframe3.is_prop = 0;
refframe3.parent_tag = "Hub";
refframe3.ref_tag = "Rot";
refframe3.origin = [ 0   0   0 ];
refframe3.orientation = [  1   0   0  ; ...
                           0   1   0  ; ...
                           0   0   1  ];

refframe4.is_prop = 1;
refframe4.num_blades = 4;
refframe4.parent_tag = "Rot";
refframe4.ref_tag = "Prop";
refframe4.node_incl = [1 2 3 4];
refframe4.origin = [ 0   0   0 ];

%% Set reference frame table

reference_frame_table = matAdapterObj.set_reference_frames({refframe1, refframe2, refframe3, refframe4});

%% Set data for prescribed motion

motionarray{1}.mot_mode = "r";
motionarray{1}.mot_axis = [1 0 0];
motionarray{1}.mot_type = "c";
motionarray{1}.ref_frame = "Rot";
motionarray{1}.t0 = 0;
motionarray{1}.tf = 2;
motionarray{1}.rate = 250*pi/3; % 2500 rpm

motionarray{2}.mot_mode = "r";
motionarray{2}.mot_axis = [0 1 0];
motionarray{2}.mot_type = "h";
motionarray{2}.ref_frame = "Hub";
motionarray{2}.t0 = 0;
motionarray{2}.tf = 2;
motionarray{2}.amp = pi/18; % 10°
motionarray{2}.omega = 20*pi;

 
% motionarray{3}.mot_mode = "r";
% motionarray{3}.mot_axis = [1 0 0];
% motionarray{3}.mot_type = "u";
% motionarray{3}.ref_frame = "PivotPoint";
% motionarray{3}.t0 = 0;
% motionarray{3}.tf = 2;
%
% load("orientationvector_pivotpoint.mat"); % Contains input normalised orientation vector to be applied at reference frame 'PivotPoint'
% motionarray{3}.vec_loc = "f";
% motionarray{3}.vec = orientationvector_pivotpoint.*pi; % Random vector multiplier
% motionarray{3}.vec_type = "p";

%% Set motion table

motion_table = matAdapterObj.set_motion_table(motionarray);

%% Setup prescribed values

matAdapterObj.set_prescribed_val();

%% Call matlab_adapter function

% Coupling function
matAdapterObj.prescribed_motion();
