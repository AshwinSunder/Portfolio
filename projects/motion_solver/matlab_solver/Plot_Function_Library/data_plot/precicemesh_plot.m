
% Function to compare mesh data in precice from different solvers
function precicemesh_plot(precicemesh_data, plot_data, leg_list, iter_list, dt_list)

   % Initialize plot max starting and ending time steps
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
    
    for i = 1:length(plot_data.fields)

        sum_val = cell(length(precicemesh_data),1); % Array to store sum of values from each node
        val = cell(length(precicemesh_data),1);% Array to store values in each node
        t = cell(length(precicemesh_data),1); % Array to store time steps
        t_max = 0; % Variable to store max final time value

        for j = 1:length(precicemesh_data) 
            
            % Save time step based on user data and pre-saved time step and number of iterations 
            if (iter_list(j)-1)*dt_list(j) < t_end
                t{j} = reshape(t_start:dt_list(j):(iter_list(j)-1)*dt_list(j),[],1);
            else
                t{j} = reshape(t_start:dt_list(j):t_end,[],1);
            end
            if t_max <= t{j}(end)
                t_max = t{j}(end)+dt_list(j);
            end

            % Initialize storage arrays
            sum_val{j} = zeros(3,length(t{j}));
            val{j} = zeros(3,plot_data.nnodes,length(t{j}));
        end

        for j = 1:plot_data.nnodes
            for k = 1:length(precicemesh_data)
                       
                momx = zeros(length(precicemesh_data),1); % Create arrays to save moments due to forces
                momy = zeros(length(precicemesh_data),1);
                momz = zeros(length(precicemesh_data),1);

                posx = zeros(length(precicemesh_data),1); % Create arrays to save positional values for moment calculation
                posy = zeros(length(precicemesh_data),1);
                posz = zeros(length(precicemesh_data),1);

                for l = t{k}(1)/dt_list(k)+1:t{k}(end)/dt_list(k)+1
                                            
                    % Moment due to forces on all nodes need to be calculated
                    if matches(plot_data.fields{i}, 'Moment')     
                        posx(k) = precicemesh_data{k}{j}(l).('PositionX');
                        posy(k) = precicemesh_data{k}{j}(l).('PositionY');
                        posz(k) = precicemesh_data{k}{j}(l).('PositionZ');
    
                        momx(k) = (precicemesh_data{k}{j}(l).('ForceZ').*posy(k)) - (precicemesh_data{k}{j}(l).('ForceY').*posz(k));          
                        momy(k) = (precicemesh_data{k}{j}(l).('ForceX').*posz(k)) - (precicemesh_data{k}{j}(l).('ForceZ').*posx(k));            
                        momz(k) = (precicemesh_data{k}{j}(l).('ForceY').*posx(k)) - (precicemesh_data{k}{j}(l).('ForceX').*posy(k)); 
                    end

                    % In each iteration, extract x,y and z values from each struct
                    val{k}(1,j,l-t{k}(1)/dt_list(k)) = precicemesh_data{k}{j}(l).(plot_data.fields{i} + "X");
                    val{k}(2,j,l-t{k}(1)/dt_list(k)) = precicemesh_data{k}{j}(l).(plot_data.fields{i} + "Y");
                    val{k}(3,j,l-t{k}(1)/dt_list(k)) = precicemesh_data{k}{j}(l).(plot_data.fields{i} + "Z");

                    % Sum up values from each node
                    sum_val{k}(1,l-t{k}(1)/dt_list(k)) = sum_val{k}(1,l-t{k}(1)/dt_list(k)) + val{k}(1,j,l-t{k}(1)/dt_list(k)) + momx(k);
                    sum_val{k}(2,l-t{k}(1)/dt_list(k)) = sum_val{k}(2,l-t{k}(1)/dt_list(k)) + val{k}(2,j,l-t{k}(1)/dt_list(k)) + momy(k);
                    sum_val{k}(3,l-t{k}(1)/dt_list(k)) = sum_val{k}(3,l-t{k}(1)/dt_list(k)) + val{k}(3,j,l-t{k}(1)/dt_list(k)) + momz(k); 

                end
            end
        end
    
        % Check if user requests data for all nodes or all co-ordinates
        if plot_data.all_nodes
            nodes = 1:plot_data.nnodes;
        else
            nodes = plot_data.node_nums;
        end
        if plot_data.all_coords
            coord = {'x','y','z'};
        else
            coord = plot_data.coords;
        end

        plot_val = cell((length(coord)+plot_data.mag)*(length(nodes)+plot_data.sum),length(precicemesh_data)); % Array to store plotting values
        tit = cell(length(plot_val)); % Array to store titles for each plot

        % Save final user-requested plot data along with plot titles
        for j = 1:length(precicemesh_data)
            ii = 1;
            jj = 1;

            for k = 1:length(nodes)+plot_data.sum
                iii = 1;
                iv = 1;
                v = 1;

                for l = 1:length(coord)+plot_data.mag

                    % Plot field values for each node in each axis
                    if ~isempty(coord) && ~isempty(nodes) && iv <= length(coord) && k <= length(nodes)
                        dat{j}(1,:) = val{j}(double(coord{l})-119,nodes(k),:);                        
                        plot_val{jj,j} = dat{j}(1,:);
                        tit{jj} = "Node " + num2str(nodes(k)) + ": " + plot_data.fields{i}(1) + "_" + coord{l} + " vs T";
                        iv = iv+1;

                    % Plot magnitude of field values of each node
                    elseif ~isempty(nodes) && iii == 1 && plot_data.mag == 1 && k <= length(nodes)
                        plot_val{jj,j}(1,:) = sqrt(val{j}(1,nodes(k),:).^2 + val{j}(2,nodes(k),:).^2 + val{j}(3,nodes(k),:).^2);
                        tit{jj} = "Node " + num2str(k) + ": " + plot_data.fields{i}(1) + "_t_o_t" + " vs T";
                        iii = 0;

                    % Plot sum of field values of all nodes in each axis
                    elseif ~isempty(coord) && plot_data.sum == 1 && v <= length(coord)
                        plot_val{jj,j} = sum_val{j}(double(coord{l})-119,:);
                        tit{jj} = "Node-all: " + plot_data.fields{i}(1) + "_" + coord{l} + " vs T";
                        v = v+1;

                    % Plot magnitude of sum of field values for all nodes
                    elseif plot_data.mag == 1 && ii == 1 && (plot_data.sum == 1 || isempty(nodes))
                        plot_val{jj,j} = sqrt(sum_val{j}(1,:).^2+sum_val{j}(2,:).^2+sum_val{j}(3,:).^2);
                        tit{jj} = "Node-all: " + plot_data.fields{i}(1) + "_t_o_t" + " vs T";
                        ii = 0;

                    end
                    jj = jj+1;
                end
            end
        end
        
        % Plot all data along with title and legend
        for j = 1:length(precicemesh_data)
            for k = 1:(length(coord)+plot_data.mag)*(length(nodes)+plot_data.sum)
                figure(k);
                plot(t{j}, plot_val{k,j}(:));
                title(tit{k});
                xlabel('Time');
                ylabel(plot_data.fields{i});
                legend(leg_list(1:j))
                xlim([t_start t_max]);
                set(gcf, 'Position', [300,250,1300,750])
                hold on
                grid on
            end
        end
    end
    hold off
end
