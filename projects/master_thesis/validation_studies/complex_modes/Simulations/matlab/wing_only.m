clearvars;clc;
port_num_old = -1;

%% Pitch amplitude
load("golandWing.mat")

dt      = 0.002;

mode1 = "e";
axis1 = [0  0  0];
type1 = "";
amp     = 0.1;
eigval  = golandWing.eigenvalue;
eigvec  = amp*real(golandWing.eigenvector);

save_location = "../../Output/wing_only/matlab/"; 

node_pos = readmatrix("../../Model/Wing/goland_wing_coupling_nodes.in",'FileType','text');

mode_shape_range = [1,3,7,9]; % First 4 mode shapes in the golandWing.eigenvector are present in these column numbers
k_range = [0.05,0.125:0.125:1.0];

for i = 1:length(mode_shape_range)
    eigmode = mode_shape_range(i);
    for k = 1:length(k_range)
        eigmode = mode_shape_range(i);
        red_freq = k_range(k);
        T = 2*pi*1.8288/(red_freq*50);
        tf = round(2*T,3)+54*dt;
        freq = (T/(2*pi*dt))*imag(eigval(eigmode));
        file_name = "wing_only-mode"+num2str(i+3)+"_k"+num2str(red_freq);
        file_name = replace(file_name,".","_")+".mat";
    
        adapter_setup_wing;
    end
end
