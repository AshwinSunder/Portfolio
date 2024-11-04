
% Function to assign name-value pair arguments to designated variables
function func_data = custom_func_set_var(input_data_type, nnodes, mot_data, tveci, nvp)
    
    % Parse input data
    par = inputParser;
    par.StructExpand = false;

    % Assign required data
    addOptional(par, 'nnodes', nnodes);
    addOptional(par, 'mot_data', mot_data);
    addOptional(par, 'tveci', tveci);
    addParameter(par, 'input_data_type', "vector");

    % Assign time-related data
    idx = zeros(size(nvp,1));
    for i = 1:size(nvp,1)

        if contains(lower(nvp{i,1}), {'t0', 'start'})
            addParameter(par, 't0i', nvp{i,2});
            idx(i) = 1;
            continue
        end
        if contains(lower(nvp{i,1}), {'tf', 'end'})
            addParameter(par, 'tfi', nvp{i,2});
            idx(i) = 1;
            continue
        end
        if contains(lower(nvp{i,1}), {'dt', 'step'})
            addParameter(par, 'dti', nvp{i,2});
            idx(i) = 1;
            continue
        end
    end

    % Assign scalar data
    if matches(input_data_type,'scalar')
        for i = 1:size(nvp,1)
            
            if contains(lower(nvp{i,1}), 'dis')
                addParameter(par, 'disi', reshape(nvp{i,2},[],1), @(x) validateattributes(x, {'numeric'}, {'finite'}, {'nonnan'}));
                idx(i) = 1;
            end
            if contains(lower(nvp{i,1}), 'pos')
                addParameter(par, 'posi', reshape(nvp{i,2},[],1), @(x) validateattributes(x, {'numeric'}, {'finite'}, {'nonnan'}));
                idx(i) = 1;
            end
            if contains(lower(nvp{i,1}), 'vel')
                addParameter(par, 'veli', reshape(nvp{i,2},[],1), @(x) validateattributes(x, {'numeric'}, {'finite'}, {'nonnan'}));
                idx(i) = 1;
            end
            if contains(lower(nvp{i,1}), 'rot')
                addParameter(par, 'roti', reshape(nvp{i,2},[],1), @(x) validateattributes(x, {'numeric'}, {'finite'}, {'nonnan'}));
                idx(i) = 1;
            end
            if contains(lower(nvp{i,1}), 'ang')
                addParameter(par, 'angi', reshape(nvp{i,2},[],1), @(x) validateattributes(x, {'numeric'}, {'finite'}, {'nonnan'}));
                idx(i) = 1;
            end
            if contains(lower(nvp{i,1}), 'vel') && contains(lower(nvp{i,1}), 'ang')
                addParameter(par, 'angveli', reshape(nvp{i,2},[],1), @(x) validateattributes(x, {'numeric'}, {'finite'}, {'nonnan'}));
                idx(i) = 1;
            end
        end

    % Assign vector data
    elseif matches(input_data_type,'vector')
        for i = 1:size(nvp,1)
            
            if contains(lower(nvp{i,1}), 'vel') 
                addParameter(par, 'v', reshape(nvp{i,2},[],1), @(x) validateattributes(x, {'numeric'}, {'finite'}, {'nonnan'}));
                idx(i) = 1;
            end
            if contains(lower(nvp{i,1}), 'dis') 
                addParameter(par, 'd', reshape(nvp{i,2},[],1), @(x) validateattributes(x, {'numeric'}, {'finite'}, {'nonnan'}));
                idx(i) = 1;
            end
            if contains(lower(nvp{i,1}), 'pos')
                addParameter(par, 'p', reshape(nvp{i,2},[],1), @(x) validateattributes(x, {'numeric'}, {'finite'}, {'nonnan'}));
                idx(i) = 1;
            end
        end
    end

    for i = 1:size(nvp,1)
        if idx(i) == 0
            addParameter(par,nvp{i,1},nvp{i,2});
        end
    end
    str = "parse(par, nnodes, mot_data, tveci, 'input_data_type', input_data_type";
    for i = 1:size(nvp,1)
        str = append(str,", '",nvp{i,1}, "' ,",string(nvp{i,2}));
    end
    str = append(str,");");
    eval(str);
    % parse(par, nnodes, mot_data, tveci,'input_data_type', input_data_type, nvp(:));
    func_data = par.Results;
end
