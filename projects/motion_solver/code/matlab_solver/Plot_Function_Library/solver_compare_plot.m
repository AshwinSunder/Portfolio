%% Create struct to hold file details for each solver

orig_data.mat_filename = "goland_wing_original.mat";
orig_data.postpro_folder_name = "../../goland_wing_coupled_test_2/dust/Postpro";
orig_data.dat_file_name = "goland_original_loads";
orig_data.solver_name = "MBDyn";
orig_data.csv_folder_name = "../../goland_wing_coupled_test_2/matlab/Itermbdyn";
orig_data.mesh_name = "MBDynNodes";
orig_data.dt = 0.001;
orig_data.num_comps = 1;

test_data.mat_filename = "goland_wing_test.mat";
test_data.postpro_folder_name = "../../goland_wing_coupled_test_2/dust/Postpro";
test_data.dat_file_name = "goland_test_loads";
test_data.solver_name = "matlab";
test_data.csv_folder_name = "../../goland_wing_coupled_test_2/matlab/Itermatlab";
test_data.mesh_name = "matlab_nodes";
test_data.dt = 0.001;
test_data.num_comps = 1;

%% Extract post-processing data

% extract_dat(orig_data);
extract_dat(test_data);

%% Extract precice mesh data

% extract_csv(orig_data);
extract_csv(test_data);

%% Load data into workspace

% load(orig_data.mat_filename);
load(test_data.mat_filename);

%% Call plot functions

% Create a struct for plot data
plot_data.t_start = 0.000;
plot_data.t_end = 2.0;
plot_data.iter = iter;
plot_data.nnodes = nnodes;
plot_data.dt = 0.001;
plot_data.fields = {'Force'};
plot_data.coords = {'x', 'y', 'z'};
plot_data.node_nums = 0;

% Call plot function to compare values of each data set

compare_precice({node_vals_MBDyn, node_vals_matlab}, plot_data, ["MBDyn" "matlab"], {orig_data, test_data});

compare_postpro({dustpost_MBDyn, dustpost_matlab}, plot_data, ["MBDyn" "matlab"], {orig_data, test_data});

%% compare_precice function
function compare_precice(node_vals, plot_data, leg_list, data_list)

   % Initialize plot starting and ending time steps
    if ~isfield(plot_data, 't_start')
        t_start = 0;
    else
        t_start = plot_data.t_start;
    end
    if ~isfield(plot_data, 't_end')
        t_end = plot_data.iter*plot_data.dt;
    else
        t_end = plot_data.t_end;
    end
    
    tim = t_start:plot_data.dt:t_end; % Initialize time array
    
    for i = 1:length(plot_data.fields)

        sum_val = cell(length(node_vals));
        t = cell(length(node_vals)); % Empty array to store time steps

        for l = 1:length(node_vals)
            t{l} = t_start:data_list{l}.dt:t_end;
            sum_val{l} = zeros(3,length(t{l}));
        end

        leg = strings([length(node_vals) 1]); % Create legend
        for j = 1:length(node_vals)
            leg(j) = append(plot_data.fields{i}(1), '-', leg_list(j));
        end

        for k = 1:(t_end-t_start)/plot_data.dt

            for j = 1:plot_data.nnodes
                    momx = zeros(length(node_vals),1); % Create arrays to save moments due to forces
                    momy = zeros(length(node_vals),1);
                    momz = zeros(length(node_vals),1);

                for l = 1:length(node_vals)
                    if mod(k, (data_list{l}.dt/plot_data.dt)) == 0
                                        
                        % Moment due to forces need to be calculated
                        if matches(plot_data.fields{i}, 'Moment') == 1     
                            disx(l) = node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).('PositionX');
                            disy(l) = node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).('PositionY');
                            disz(l) = node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).('PositionZ');
        
                            momx(l) = (node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).('ForceZ').*disy(l)) - (node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).('ForceY').*disz(l));
        
                            momy(l) = (node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).('ForceX').*disz(l)) - (node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).('ForceZ').*disx(l));
        
                            momz(l) = (node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).('ForceY').*disx(l)) - (node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).('ForceX').*disy(l)); 
                        end
    
                        % In each iteration, extract x,y and z values from each struct
                        xval(l) = node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).(plot_data.fields{i} + "X");
                        yval(l) = node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).(plot_data.fields{i} + "Y");
                        zval(l) = node_vals{l}{j}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).(plot_data.fields{i} + "Z");
    
                        % Sum up values from each node
                        sum_val{l}(1, k*(plot_data.dt/data_list{l}.dt)) = sum_val{l}(1, k*(plot_data.dt/data_list{l}.dt)) + xval(l) + momx(l);
                        sum_val{l}(2, k*(plot_data.dt/data_list{l}.dt)) = sum_val{l}(2, k*(plot_data.dt/data_list{l}.dt)) + yval(l) + momy(l);
                        sum_val{l}(3, k*(plot_data.dt/data_list{l}.dt)) = sum_val{l}(3, k*(plot_data.dt/data_list{l}.dt)) + zval(l) + momz(l); 
                    end
                end
            end
        end
    
        % Plot mean amplitude and add to legend
        for l = 1:length(node_vals)

        % Calculate mean amplitude of given parameter
        mean_val{l} = sqrt(sum_val{l}(1, :).^2 + sum_val{l}(2, :).^2 + sum_val{l}(3, :).^2);

            figure(i);
            plot(t{l}, mean_val{l}, 'LineWidth', 2*l-1);
            hold on
        end
    
        % Add title, labels and legend
        title(plot_data.fields{i} + " vs Time");
        xticks('auto');
        xticklabels('auto');
        xlabel('Time');
        ylabel(plot_data.fields{i});
        xlim([tim(1) tim(end)]);
        legend(leg);
        hold off
    end     
end

%% compare_precice function
function compare_postpro(postpro_dat, plot_data, leg_list, data_list)

    % Initialize plot starting and ending time steps
    if ~isfield(plot_data, 't_start')
        t_start = 0;
    else
        t_start = plot_data.t_start;
    end
    if ~isfield(plot_data, 't_end')
        t_end = plot_data.iter*plot_data.dt;
    else
        t_end = plot_data.t_end;
    end

    for i = 1:length(postpro_dat)
        t{i} = t_start:data_list{i}.dt:t_end;
    end
    for i = 1:length(plot_data.fields)

        val = cell(length(postpro_dat));
        for j = 1:length(postpro_dat)
        
            val{j} = zeros(1, length(t{j})); % Create array for mean calculation
        end

        leg = strings([length(postpro_dat) 1]); % Create legend
        for j = 1:length(postpro_dat)
            leg(j) = append(plot_data.fields{i}(1), '-', leg_list(j));
        end

        for k = 1:(t_end-t_start)/plot_data.dt
            for l = 1:length(postpro_dat)
                % Extract data from postprocessing data
                if mod(k, data_list{l}.dt/plot_data.dt) == 0
                    val{l}(1, k*(plot_data.dt/data_list{l}.dt)) = sqrt(postpro_dat{l}{1}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).(plot_data.fields{i}(1) + "x").^2 + ...
                                                                       postpro_dat{l}{1}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).(plot_data.fields{i}(1) + "y").^2 + ...
                                                                       postpro_dat{l}{1}((k+t_start/plot_data.dt)*(plot_data.dt/data_list{l}.dt)).(plot_data.fields{i}(1) + "z").^2 );
                end
            end
        end
    
        % Plot mean amplitude and add to legend
        for l = 1:length(postpro_dat)
            figure(i);
            plot(t{l}, val{l}, 'LineWidth', 2*l-1);
            hold on
        end
    
        % Add title, labels and legend
        title(plot_data.fields{i} + " vs Time");
        xticks('auto');
        xticklabels('auto');
        xlabel('Time');
        ylabel(plot_data.fields{i});
        xlim([t_start t_end]);
        legend(leg);
        hold off
    end     
end

%% extract_csv function
function extract_csv(data)
    % Define variables
    i = 0;
    
    % Read input data files into tables
    while true
        i = i+1;
        file = data.csv_folder_name + "/" + data.mesh_name + "-" + data.solver_name + ".dt" + i + ".csv";
    
        if isfile(file)
            tables{i}  = readtable(file);
        end
        if ~isfile(file)
            break
        end
    end
    % Seperate the nodal values
    fields = matlab.lang.makeValidName(tables{1}.Properties.VariableNames);
    nnodes = height(tables{1});
    iter   = i-1;    
    vals = cell(iter, length(fields));
    
    for i = 1:nnodes
        for j = 1:iter
            for k = 1:length(fields)
                field_val  = tables{j}.(fields{k});
                vals{j, k} = field_val(i, 1);
            end
        end
        node_vals = genvarname("node_vals_" + data.solver_name);
        node_vals = convertCharsToStrings(node_vals);
        eval(node_vals + "{i} = cell2struct(vals, fields, 2);");
    end

    % Save data as mat file
    str = append("save(data.mat_filename, 'iter', 'nnodes', '", node_vals, "', ", '"-append");');
    eval(str);    
end

%% extract_dat function
function extract_dat(data)

    for i = 1:data.num_comps
        if data.num_comps > 1
            file_name = data.postpro_folder_name + "/" + data.dat_file_name + "0" + num2str(i) + ".dat";
        else
            file_name = data.postpro_folder_name + "/" + data.dat_file_name + ".dat";
        end
        if isfile(file_name)
            wing_arrays{i} = importdata(file_name, ' ', 4);
        end
    end

    file_name = data.postpro_folder_name + "/" + data.dat_file_name + "_all.dat";
    if isfile(file_name)
        wing_arrays{data.num_comps+1} = importdata(file_name, ' ', 4);
    end

    % Convert data into a table
    wing_fields =  ["t" "Fx" "Fy" "Fz" "Mx" "My" "Mz"];
    dustpost = genvarname("dustpost_" + data.solver_name);
    dustpost = convertCharsToStrings(dustpost);
    for i = 1:length(wing_arrays)
        if ~isempty(wing_arrays)
            wing_data{i} = array2table(wing_arrays{i}.data(:, 1:7),'VariableNames', wing_fields);
            if data.num_comps > 1
                eval(dustpost + "{" + num2str(i)+ "} = table2struct(wing_data" + num2str(i) + ");");
            else
                eval(dustpost + "{" + num2str(i)+ "} = table2struct(wing_data{i});");
            end
        end
    end

    % Save structs to .mat file
    eval("save(data.mat_filename, '" + dustpost + "');");
end
