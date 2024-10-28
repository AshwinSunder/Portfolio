
% Function to assign arguments and solve custom function
function [output, mot_data] = custom_func(nnodes, mot_data, input_data_type, tveci, initial_data)

    % Convert input data into a cell array
    if ~iscell(mot_data.arg_in)
        mot_data.arg_in = num2cell(mot_data.arg_in);
    end
    if ~iscell(mot_data.val_in)
        mot_data.val_in = num2cell(mot_data.val_in);
    end

    % Create a cell arry containing name_value pairs
    n = mot_data.arg_in;
    v = mot_data.val_in;
    nvp = name_value_pairs(n,v);

    % Set variables
    func_data = custom_func_set_var(input_data_type, nnodes, mot_data, tveci, nvp);

    % Assign custom function input values based on user input
    custom_func_in(func_data);

    % Use the custom function to solve for required data
    if length(mot_data.val_out) ~= length(mot_data.arg_out)
        mot_data.val_out = cell(length(mot_data.arg_out),1);
    end
    [mot_data.val_out{:}] = mot_data.func(mot_data.val_in{:});

    % Retrieve all output data into required fields
    if nargin > 4
        [time_data, scalar_data, scalar_final_data, vector_data, vector_final_data] = custom_func_out(func_data, mot_data, initial_data);
    else
        [time_data, scalar_data, scalar_final_data, vector_data, vector_final_data] = custom_func_out(func_data, mot_data);
    end

    % Convert output data into a cell array
    if ~iscell(mot_data.arg_out)
        mot_data.arg_out = num2cell(mot_data.arg_out);
    end

    % Save all structs into one returned struct
    output.time_data         = time_data;
    output.scalar_data       = scalar_data;
    output.vector_data       = vector_data;
    output.scalar_final_data = scalar_final_data;
    output.vector_final_data = vector_final_data;        
end