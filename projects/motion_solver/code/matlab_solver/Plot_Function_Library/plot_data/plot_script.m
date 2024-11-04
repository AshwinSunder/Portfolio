%% Load data into workspace

clearvars;
load("test_data.mat");

%% Define plot parameters

% Create a struct for plot data
plot_data.t_start = 0.000;
plot_data.t_end = 1.999;
plot_data.nnodes = 9;
plot_data.dt = 0.001;

plot_data.fields = {'Force'};
plot_data.coords = {};
plot_data.node_nums = [];

plot_data.mag = 1;
plot_data.sum = 1;
plot_data.all_coords = 0;
plot_data.all_nodes = 0;

%% Extract required data

fn = {"erk 4 dt 0.0005", "erk 4 dt 0.001", "erk 4 dt 0.002"};

leg_data = strings([length(fn),1]);
precicemesh_data = cell(1,length(fn));
dustpost_data = cell(1,length(fn));

for i = 1:length(fn)
    field_name = erase(strrep(fn{i},'.','_')," ");
    leg_data(i) = strrep(fn{i}, '_', '.');
    varname = lower(matlab.lang.makeValidName(leg_data(i)));
    eval("precicemesh_data{1,i} = " + varname + ";");
    eval("dustpost_data{1,i} = " + varname + ";");

end

%% Plot precicemesh data

% plot_precicemesh(precicemesh_data, plot_data, leg_data);

%% Plot dustpost data

plot_dustpost(dustpost_data, plot_data, leg_data);