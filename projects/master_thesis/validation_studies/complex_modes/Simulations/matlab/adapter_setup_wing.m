clc;

%% Simulation setup

% Basic configuration data
sim_data.nnodes = 17; 
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
refframe1.node_pos = node_pos;

%% Set reference frame table

refframe_array = {refframe1};

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

%% Set motion table

motionarray = {motdata1};

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
