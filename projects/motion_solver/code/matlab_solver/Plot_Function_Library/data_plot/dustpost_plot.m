
% Function to compare mesh data in precice from different solvers
function dustpost_plot(dustpost_data, plot_data, leg_list, iter_list, dt_list)

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

        sum_val = cell(length(dustpost_data)); % Array to store sum of values from each node
        val = cell(length(dustpost_data));% Array to store values in each node
        t = cell(length(dustpost_data)); % Array to store time steps
        t_max = 0; % Variable to store max final time value

        for j = 1:length(dustpost_data) 
            
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

        for j = 1:length(dustpost_data)
            for k = t{j}(1)/dt_list(j)+1:t{j}(end)/dt_list(j)+1
                for l = 1:length(dustpost_data{j})

                    % Save values from each dust post processing file into the cell
                    val{j}(1,l,k) = dustpost_data{j}{l}(k).(plot_data.fields{i}(1) + "x");
                    val{j}(2,l,k) = dustpost_data{j}{l}(k).(plot_data.fields{i}(1) + "y");
                    val{j}(3,l,k) = dustpost_data{j}{l}(k).(plot_data.fields{i}(1) + "z");

                    if length(dustpost_data{j}) == 1 % Check if there is just one post processing file                        
                            sum_val{j}(1,k) = val{j}(1,l,k);
                            sum_val{j}(2,k) = val{j}(2,l,k);
                            sum_val{j}(3,k) = val{j}(3,l,k);

                    elseif length(dustpost_data{j}) == plot_data.nnodes+1 % Check if there is an additional 'all' post processing file
                        if l == length(dustpost_data{j})
                            sum_val{j}(1,k) = val{j}(1,l,k);
                            sum_val{j}(2,k) = val{j}(2,l,k);
                            sum_val{j}(3,k) = val{j}(3,l,k);                                  
                        end

                    else % Add values from each post processing file
                        sum_val{j}(1,k) = sum_val{j}(1,idx)+val{j}(1,l,k);
                        sum_val{j}(2,k) = sum_val{j}(2,idx)+val{j}(2,l,k);
                        sum_val{j}(3,k) = sum_val{j}(3,idx)+val{j}(3,l,k);

                    end
                end
            end
        end

        % Check if user requests data for all nodes
        for j = 1:length(dustpost_data)           
            if length(dustpost_data{j}) == 1
                nodes{j} = [];
            elseif plot_data.all_nodes
                nodes{j} = 1:plot_data.nnodes;
            else
                nodes{j} = plot_data.node_nums;
            end
        end
    
        % Check if user requests data for all co-ordinates
        if plot_data.all_coords
            coord = {'x','y','z'};
        else
            coord = plot_data.coords;
        end

        plot_val = cell((length(coord)+plot_data.mag)*(length(nodes{j})+plot_data.sum),length(dustpost_data)); % Array to store plotting values
        tit = cell(length(plot_val)); % Array to store titles for each plot

        % Save final user-requested plot data along with plot titles
        for j = 1:length(dustpost_data)
            ii = 1;
            jj = 1;

            for k = 1:length(nodes{j})+plot_data.sum
                iii = 1;
                iv = 1;
                v = 1;

                for l = 1:length(coord)+plot_data.mag

                    % Plot field values for each node in each axis
                    if ~isempty(coord) && ~isempty(nodes{j}) && iv <= length(coord) && k <= length(nodes{j})
                        dat(1,:) = val{j}(double(coord{l})-119,nodes{j}(k),:);                        
                        plot_val{jj,j} = dat(1,:);
                        tit{jj} = "Node " + num2str(nodes{j}(k)) + ": " + plot_data.fields{i}(1) + "_" + coord{l} + " vs T";
                        iv = iv+1;

                    % Plot magnitude of field values of each node
                    elseif ~isempty(nodes{j}) && iii == 1 && plot_data.mag == 1 && k <= length(nodes{j})
                        plot_val{jj,j}(1,:) = sqrt(val{j}(1,nodes{j}(k),:).^2 + val{j}(2,nodes{j}(k),:).^2 + val{j}(3,nodes{j}(k),:).^2);
                        tit{jj} = "Node " + num2str(k) + ": " + plot_data.fields{i}(1) + "_t_o_t" + " vs T";
                        iii = 0;

                    % Plot sum of field values of all nodes in each axis
                    elseif ~isempty(coord) && plot_data.sum == 1 && v <= length(coord)
                        plot_val{jj,j} = sum_val{j}(double(coord{l})-119,:);
                        tit{jj} = "Node-all: " + plot_data.fields{i}(1) + "_" + coord{l} + " vs T";
                        v = v+1;

                    % Plot magnitude of sum of field values for all nodes
                    elseif plot_data.mag == 1 && ii == 1 && (plot_data.sum == 1 || isempty(nodes{j}))
                        plot_val{jj,j} = sqrt(sum_val{j}(1,:).^2+sum_val{j}(2,:).^2+sum_val{j}(3,:).^2);
                        tit{jj} = "Node-all: " + plot_data.fields{i}(1) + "_t_o_t" + " vs T";
                        ii = 0;

                    end
                    jj = jj+1;
                end
            end
        end
        
        % Plot all data along with title and legend
        for j = 1:length(dustpost_data)
            for k = 1:(length(coord)+plot_data.mag)*(length(nodes{j})+plot_data.sum)
                figure(k);
                plot(t{j}, plot_val{k,j}(t_start/dt_list(j)+1:t_start/dt_list(j)+length(t{j})));
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
