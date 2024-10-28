%% Load data into workspace

clearvars;
load("testdata.mat");

%% Define plot parameters

% Create a struct for plot data
plot_data.t_start = 0.000;
plot_data.t_end = 1.999;
plot_data.nnodes = nnodes;
plot_data.dt = 0.001;

plot_data.fields = {'Force'};
plot_data.coords = {'z'};
plot_data.node_nums = [];

plot_data.mag = 0;
plot_data.sum = 1;
plot_data.all_coords = 0;
plot_data.all_nodes = 0;

%% Extract required data

fn = {"mbdyn", "newmark2undamped dt 0.001", "genalpha30_333 dt 0.001"};

precicemesh_data = cell(length(fn),1);
dustpost_data = cell(length(fn),1);
leg_data = strings([length(fn),1]);
iter_list = zeros(length(fn),1);
dt_list = zeros(length(fn),1);

for i = 1:length(fn)
    field_name = erase(strrep(fn{i},'.','_')," ");
    precicemesh_data{i} = precicemesh.(field_name);
    dustpost_data{i} = dustpost.(field_name);
    leg_data(i) = strrep(fn{i}, '0_', '0.');
    iter_list(i) = iter.(field_name);
    dt_list(i) = dt.(field_name);
end

%% Plot precicemesh data

precicemesh_plot(precicemesh_data, plot_data, leg_data, iter_list, dt_list);

%% Plot dustpost data

% dustpost_plot(dustpost_data, plot_data, leg_data, iter_list, dt_list);