
% Function to assign input argument values
function custom_func_in(inp_data)

    % Save all input data into respective fields
    % Required data
    nnodes   = inp_data.nnodes; 
    tveci    = inp_data.tveci;
    mot_data = inp_data.mot_data;

    % Time related data
    if isfield(inp_data, 't0i') 
        t0i = inp_data.t0i;
    else
        t0i = tveci(1);
    end
    if isfield(inp_data, 'tfi')
        tfi = inp_data.tfi;
    else
        tfi = tveci(end);
    end
    if isfield(inp_data, 'dti')
        dti = inp_data.dti;
    else
        dti = (tveci(end)-tveci(1))/length(tveci);
    end
   
    % Input scalar data provided
    if isfield(inp_data, 'disi') 
        disi = inp_data.disi;
    end
    if isfield(inp_data, 'posi')
        posi = inp_data.posi;
    end
    if isfield(inp_data, 'veli')
        veli = inp_data.veli;
    end
    if isfield(inp_data, 'roti')
        roti = inp_data.roti;
    end
    if isfield(inp_data, 'angi')
        angi = inp_data.angi;
    end
    if isfield(inp_data, 'angveli')
        angveli = inp_data.angveli;
    end

    % Input vector data provided
    if isfield(inp_data, 'v') 
        veli = zeros(length(inp_data.v),1);
        angveli = zeros(length(inp_data.v),1); 
        dim = 0.5*length(inp_data.v)/nnodes;

        for i = 1:nnodes
            veli(i*dim+1:(i+1)*dim,1) = inp_data.v(i*dim*2+1:(2*i+1)*dim,1);
            angveli((i+1)*dim+1:(i+1)*dim*2,1) = inp_data.v((2*i+1)*dim+1:(i+1)*dim*2,1);
        end
    end
    if isfield(inp_data, 'd')
        disi = zeros(length(inp_data.d),1);
        roti = zeros(length(inp_data.d),1); 
        dim = 0.5*length(inp_data.v)/nnodes;

        for i = 1:nnodes
            disi(i*dim+1:(i+1)*dim,1) = inp_data.d(i*dim*2+1:(2*i+1)*dim,1);
            roti((i+1)*dim+1:(i+1)*dim*2,1) = inp_data.d((2*i+1)*dim+1:(i+1)*dim*2,1);
        end
    end
    if isfield(inp_data, 'p')
        posi = zeros(length(inp_data.p),1);
        angi = zeros(length(inp_data.p),1); 
        dim = 0.5*length(inp_data.v)/nnodes;

        for i = 1:nnodes
            posi(i*dim+1:(i+1)*dim,1) = inp_data.p(i*dim*2+1:(2*i+1)*dim,1);
            angi((i+1)*dim+1:(i+1)*dim*2,1) = inp_data.p((2*i+1)*dim+1:(i+1)*dim*2,1);
        end
    end

    % Assign custom function input values based on user input
    for j = 1:length(mot_data.arg_in) 

        % Save number of nodes if needed
        if contains(mot_data.arg_in{j}, 'node') && ~isempty(mot_data.val_in{j})
            mot_data.val_in{j} = nnodes;
        end

        % Save input time-related arguments' values
        if contains(mot_data.arg_in{j}, {'t0', 'start'}) && ~isempty(mot_data.val_in{j})
            mot_data.val_in{j} = t0i;
            continue
        end
        if contains(mot_data.arg_in{j}, {'tf', 'end'}) && ~isempty(mot_data.val_in{j})
            mot_data.val_in{j} = tfi;
            continue
        end
        if contains(lower(mot_data.arg_in{j}), {'dt', 'step'}) && ~isempty(mot_data.val_in{j})
            mot_data.val_in{j} = dti;
            continue
        end
        if contains(mot_data.arg_in{j}, 'tvec') && ~isempty(mot_data.val_in{j})
            mot_data.val_in{j} = tveci;
            continue
        end

        % Save input scalar data values
        if contains(lower(mot_data.arg_in{j}), 'dis') && ~contains(lower(mot_data.arg_in{j}), 'vector') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','y','z'}) || length(disi) == nnodes
                mot_data.val_in{j} = disi;
            else
                mot_data.val_in{j} = nonzeros(reshape(disi,[3,nnodes]).*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}),'y');count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end
        if contains(lower(mot_data.arg_in{j}), 'pos') && ~contains(lower(mot_data.arg_in{j}), 'vector') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','y','z'}) || length(posi) == nnodes
                mot_data.val_in{j} = posi;
            else
                mot_data.val_in{j} = nonzeros(reshape(posi,[3,nnodes]).*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}),'y');count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end
        if contains(lower(mot_data.arg_in{j}), 'vel') && ~contains(lower(mot_data.arg_in{j}), 'ang') && ~contains(lower(mot_data.arg_in{j}), 'vector') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','z'}) || length(veli) == nnodes || count(lower(mot_data.arg_in{j}), 'y')-count(lower(mot_data.arg_in{j}), 'velocity') > 0
                mot_data.val_in{j} = veli;
            else
                mot_data.val_in{j} = nonzeros(reshape(veli,[3,nnodes]).*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}), 'velocity')+count(lower(mot_data.arg_in{j}), 'y')-1;count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end
        if contains(lower(mot_data.arg_in{j}), 'rot') && ~contains(lower(mot_data.arg_in{j}), 'vector') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','y','z'}) || length(roti) == nnodes
                mot_data.val_in{j} = roti;
            else
                mot_data.val_in{j} = nonzeros(reshape(roti,[3,nnodes]).*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}),'y');count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end
        if contains(lower(mot_data.arg_in{j}), 'ang') && ~contains(lower(mot_data.arg_in{j}), 'vel') && ~contains(lower(mot_data.arg_in{j}), 'vector') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','y','z'}) || length(angi) == nnodes
                mot_data.val_in{j} = angi;
            else
                mot_data.val_in{j} = nonzeros(reshape(angi,[3,nnodes]).*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}),'y');count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end
        if contains(lower(mot_data.arg_in{j}), 'vel')  && contains(lower(mot_data.arg_in{j}), 'ang') && ~contains(lower(mot_data.arg_in{j}), 'vector') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','z'}) || length(angveli) == nnodes || count(lower(mot_data.arg_in{j}), 'y')-count(lower(mot_data.arg_in{j}), 'velocity') > 0
                mot_data.val_in{j} = angveli;
            else
                mot_data.val_in{j} = nonzeros(reshape(angveli,[3,nnodes]).*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}), 'velocity')+count(lower(mot_data.arg_in{j}), 'y')-1,'y';count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end

        % Save input vector data values
        if contains(lower(mot_data.arg_in{j}), 'vector') && contains(lower(mot_data.arg_in{j}), 'vel') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','z'}) || (length(veli) == nnodes && length(angveli) == nnodes) || count(lower(mot_data.arg_in{j}), 'y')-count(lower(mot_data.arg_in{j}), 'velocity') > 0
                mot_data.val_in{j} = [veli;angveli];
            else
                mot_data.val_in{j} = nonzeros([veli angveli].*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}), 'velocity')+count(lower(mot_data.arg_in{j}), 'y')-1,'y';count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end
        if contains(lower(mot_data.arg_in{j}), 'vector') && contains(lower(mot_data.arg_in{j}), 'dis') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','y','z'}) || (length(disi) == nnodes && length(roti) == nnodes)
                mot_data.val_in{j} = [disi;roti];
            else
                mot_data.val_in{j} = nonzeros([disi roti].*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}),'y');count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end
        if contains(lower(mot_data.arg_in{j}), 'vector') && contains(lower(mot_data.arg_in{j}), 'pos') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','y','z'}) || (length(poti) == nnodes && length(angi) == nnodes)
                mot_data.val_in{j} = [poti;angi];
            else
                mot_data.val_in{j} = nonzeros([poti angi].*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}),'y');count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end
        if contains(lower(mot_data.arg_in{j}), 'vector') && contains(lower(mot_data.arg_in{j}), 'input') && contains(lower(mot_data.arg_in{j}), 'dis') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','z'}) || (length(disi) == nnodes && length(roti) == nnodes && length(veli) == nnodes && length(angveli) == nnodes) || count(lower(mot_data.arg_in{j}), 'y')-count(lower(mot_data.arg_in{j}), 'velocity') > 0
                mot_data.val_in{j} = [disi;roti;veli;angveli];
            else
                mot_data.val_in{j} = nonzeros([disi roti veli angveli].*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}), 'velocity')+count(lower(mot_data.arg_in{j}), 'y')-1,'y';count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end
        if contains(lower(mot_data.arg_in{j}), 'vector') && contains(lower(mot_data.arg_in{j}), 'input') && contains(lower(mot_data.arg_in{j}), 'pos') && ~isempty(mot_data.val_in{j})
            if ~contains(lower(mot_data.arg_in{j}), {'x','z'}) || (length(posi) == nnodes && length(angi) == nnodes && length(veli) == nnodes && length(angveli) == nnodes) || count(lower(mot_data.arg_in{j}), 'y')-count(lower(mot_data.arg_in{j}), 'velocity') > 0
                mot_data.val_in{j} = [posi;angi;veli;angveli];
            else
                mot_data.val_in{j} = nonzeros([posi angi veli angveli].*[count(lower(mot_data.arg_in{j}),'x');count(lower(mot_data.arg_in{j}), 'velocity')+count(lower(mot_data.arg_in{j}), 'y')-1,'y';count(lower(mot_data.arg_in{j}),'z')]);
            end
            continue
        end
    end
end
