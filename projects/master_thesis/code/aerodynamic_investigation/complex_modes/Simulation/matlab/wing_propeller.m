clearvars;clc;
port_num_old = -1;

%% Pitch amplitude
load("golandWing.mat")

dt      = 0.0005;

mode1 = "e";
axis1 = [0  0  0];
type1 = "";
amp     = 0.1;
eigval  = golandWing.eigenvalue;
eigvec  = amp*real(golandWing.eigenvector);

mode2 = "r";
axis2 = [1 0 0];
type2 = "c";
rot_rate = 2*pi*50/(1.2*1.524);

save_location = "../../Output/wing_propeller/matlab/"; 

node_pos = [readmatrix("../../Model/Wing/goland_wing_coupling_nodes.in",'FileType','text'); ...
            0,0,1; ...
            0,0,2; ...
            0,0,3; ...
            0,0,4; ...
            ];

mode_shape_range = 1:2:3;
hub_parent_range = [9,13,17];
k_range = [0.05 0.125:0.125:1.0];

for j = 1:length(hub_parent_range)
    parent1 = hub_parent_range(j);
    parent_pos = round(node_pos(parent1,2)/6.096,2);
    for i = 1:length(mode_shape_range)
        eigmode = mode_shape_range(i);
        for k = 1:length(k_range)
            red_freq = k_range(k);
            T = 2*pi*1.8288/(red_freq*50);
            tf = round(1.5*T,3)+104*dt;
            freq = (T/(2*pi*dt))*imag(eigval(eigmode));

            file_name = "wing_propeller_mode"+num2str(i)+"_y"+num2str(parent_pos)+"_k"+num2str(round(red_freq,2));
            file_name = replace(file_name,".","_")+".mat";

            adapter_setup_wing_propeller;
        end
    end
end