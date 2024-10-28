% Function to extract data from built-in precice mesh data tool (csv files)
function extract_precicemesh(data)
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
    iter_precicemesh = i-1;    
    vals = cell(iter_precicemesh, length(fields));
    
    for i = 1:nnodes
        for j = 1:iter_precicemesh
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
    if exist(data.mat_filename,"file")
        str = append("save(data.mat_filename, 'iter_precicemesh', 'nnodes', '", node_vals, "', ", '"-append");');
    else
        str = append("save(data.mat_filename, 'iter_precicemesh', 'nnodes', '", node_vals, "'");
    end
    
    eval(str);    
end
