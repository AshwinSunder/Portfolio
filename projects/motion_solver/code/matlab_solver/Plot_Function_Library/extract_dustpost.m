% Function to extract integral load from dust postprocessing tool (dat files)
function extract_dustpost(data)

    % Assign each dat file into an array
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

    % Check if an 'all' dat file exists
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

    % Save total iterations
    iter_dustpost = height(wing_data{1});

    % Save structs to .mat file
    if exist(data.mat_filename,"file")
        eval(append("save(data.mat_filename, '", dustpost, "' 'iter_dustpost' ", ', "-append");'));
    else
        eval(append("save(data.mat_filename, '", dustpost, "' 'iter_dustpost');"));
    end
end


