clc;

%% Simulation setup

% Basic configuration data
sim_data.nnodes = 21; 
sim_data.dim = 3;
sim_data.dt = dt;
sim_data.tstart = 0;
sim_data.tfinal = tf;

%% Create a matlab_adapter object

% Save location and file name details
make_folder = false;

% Create matlab_adapter object
matAdapterObj = matlab_adapter(sim_data, file_name, save_location, make_folder);

% Create refConfigNodes.in file
writematrix(node_pos,'refConfigNodes.in','Delimiter','space','FileType','text');

%% Set data for reference frame

refframe1.is_prop = 0;
refframe1.parent_tag = 0;
refframe1.ref_tag = "Wing";
refframe1.origin = [ 0   0   0 ];
refframe1.orientation = [  1   0   0  ; ...
                           0   1   0  ; ...
                           0   0   1  ];
refframe1.node_incl = 1:17;
refframe1.node_pos = node_pos(refframe1.node_incl,:);

refframe2.is_prop = 0;
refframe2.parent_tag = parent1;
refframe2.ref_tag = "PivotPoint";
refframe2.origin = [ -0.75*1.8288   0   0 ];
refframe2.orientation = [  -1   0   0  ; ...
                           0   1   0  ; ...
                           0   0   -1  ];

refframe3.is_prop = 0;
refframe3.parent_tag = "PivotPoint";
refframe3.ref_tag = "Hub";
refframe3.origin = [ 0   0   0 ];
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
refframe5.parent_tag = "Rot";
refframe5.ref_tag = "Prop";
refframe5.origin = [ 0   0   0 ];
refframe5.num_blades = 4;
refframe5.node_incl = 18:21;

%% Set reference frame table

refframe_array = {refframe1,refframe2,refframe3,refframe4,refframe5};

reference_frame_table = matAdapterObj.set_reference_frames(refframe_array);

%% Set data for prescribed motion

motdata1.mot_mode = mode1;
motdata1.mot_axis = axis1;
motdata1.mot_type = type1;
motdata1.ref_frame = "Wing";
motdata1.t0 = 0;
motdata1.tf = tf;
motdata1.freq = freq;
motdata1.eigval = eigval;
motdata1.eigvec = eigvec;
motdata1.mode = eigmode;
motdata1.damp = 0;

motdata2.mot_mode = mode2;
motdata2.mot_axis = axis2;
motdata2.mot_type = type2;
motdata2.ref_frame = "Rot";
motdata2.rate = rot_rate;

%% Set motion table

motionarray = {motdata1,motdata2};

motion_table = matAdapterObj.set_motion_table(motionarray);

%% Setup prescribed values

matAdapterObj.set_prescribed_val();

%% Call matlab_adapter function

% Text file containing port number
port_file = "port.txt";

while true
    fid = fopen(port_file,'r');
    port_num_new = fscanf(fid,"%d");

    if port_num_new ~= port_num_old
        port_num_old = port_num_new;
        break
    end
end

% Coupling function
matAdapterObj.prescribed_motion(port_file);

port_num_old = port_num_new;
