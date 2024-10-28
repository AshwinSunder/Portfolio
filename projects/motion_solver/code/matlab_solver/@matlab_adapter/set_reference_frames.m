
% Function to create reference frame table
function reference_frame_table = set_reference_frames(obj,refframes)
    %   Short Description
    %% Input
    %
    %
    %% Output
    %
    %

    %% Check if reference frames have been provided; if yes, check if all are structures
    assert(length(refframes) >= 1 ,"No reference frame structures have been provided.");
    for i = 1:length(refframes)
        assert(isstruct(refframes{i}),"Reference frames have not been provided as structures.");
    end

    %% Create a cell array of parsed reference frame structs
    nprop    = 0;
    nref_tot = 0;
    k        = 0;
    empty_parenttag_index = [];
    
    for i = 1:length(refframes)
        % Ensure ref_tag is string
        refframes{i}.ref_tag = string(refframes{i}.ref_tag);

        if ~refframes{i}.is_prop % Non-Propeller reference frame
            nref_tot                   = nref_tot+1;
            parsed_refframes{nref_tot} = parse_refframe_data(refframes{i});

        else % Propeller reference frame
            nprop     = nprop+1;
            nref      = refframes{i}.num_blades;
            node_incl = refframes{i}.node_incl;
            
            for nblade = 1:nref
                nref_tot = nref_tot+1;

                refframes{i}.ref_tag     = "Prop_0"+string(nprop)+'_0'+string(nblade);
                refframes{i}.orientation = [0 0 1;-1 0 0;0 -1 0]*vec2matr([0 0 (nblade-1)*2*pi/nref],10^-6); % First blade in negative z-direction of parent reference frame; rotate in x-axis based on blade number
                refframes{i}.node_incl   = node_incl(nblade);
                refframes{i}.node_pos    = refframes{i}.origin;

                parsed_refframes{nref_tot} = parse_refframe_data(refframes{i});
            end
        end

        % Check if the ref frame is based on a node and create an additional ref frame for this node     
        if ismember(string(refframes{i}.parent_tag),string(1:obj.nnodes))
            % Create new reference frame based on desired node
            nref_tot = nref_tot+1;

            ref_tmp.ref_tag            = string(refframes{i}.parent_tag);
            ref_tmp.parent_tag         = "";
            ref_tmp.origin             = [];
            parsed_refframes{nref_tot} = parse_refframe_data(ref_tmp);

            k = k+1;
            empty_parenttag_index(k) = nref_tot;
        end
    end

    %% Search for parent_Tags that are currently ""
    for i = 1:length(empty_parenttag_index)
        id   = empty_parenttag_index(i);
        node = str2double(parsed_refframes{id}.ref_tag);
        
        % Search for parent tag
        for j = 1:length(parsed_refframes)
            if ismember(node,parsed_refframes{j}.node_incl)
                parsed_refframes{id}.parent_tag = parsed_refframes{j}.ref_tag;% Set parent tag

                node_loc                    = find(parsed_refframes{j}.node_incl == node);
                parsed_refframes{id}.origin = parsed_refframes{j}.node_pos(node_loc,:); % Local origin
                break
            end
        end
    end

    %% Create an id vector to rearrange parsed reference frames based on parent-child hierarchy
    ref_par_vect = repmat("",length(parsed_refframes),3);
    for i = 1:length(parsed_refframes)
        ref_par_vect(i,:) = [num2str(i) parsed_refframes{i}.ref_tag string(parsed_refframes{i}.parent_tag)]; 
    end

    par_tag = "0"; % First level starts with the global parent
    id_vect = [];
    while ~isempty(par_tag)
    par_tag_new = [];
        for i = 1:length(par_tag)
            id_vect     = [id_vect;ref_par_vect(ref_par_vect(:,3) == par_tag(i),1)];
            par_tag_new = [par_tag_new;ref_par_vect(ref_par_vect(:,3) == par_tag(i),2)];
        end
        par_tag = [];
        par_tag = par_tag_new;
    end

    id_vect = str2double(id_vect);

    %% Check if a cycle of parent-child tags are created
    % for i = 1:height(ref_frames)-1
    %     assert(all(matches(string(ref_frames.ref_tag(i+1:end)),string(ref_frames.parent_tag(1:i))) == 0), "Parent-child loop created");
    % end
    % 
    % 
    % % Check if each reference frame has atleast one included or dependent node; if yes, check if each tree uses each node just once
    % nodes = [];
    % for i = 1:height(ref_frames)
    %     nodes = [nodes;ref_frames(i).node_incl];
    % end
    % assert(~isempty(nodes), "Node: "+ num2str(setdiff(1:obj.nnodes,nodes)) + "-> hasn#t been defined or has been defined more than once");

    %% Add global locations of origin and global orientations of each reference frame
    for i = 1:length(parsed_refframes)
        idx = id_vect(i);

        if string(parsed_refframes{idx}.parent_tag) == num2str(0) % Global parent
            parent_origin_global      = zeros(1,obj.dim);
            parent_orientation_global = eye(obj.dim);

        else % Non-global parent
            parent_frame = ref_par_vect(idx,3);
            parID    = str2double(ref_par_vect(ref_par_vect(:,2) == parent_frame,1));

            parent_origin_global      = parsed_refframes{parID}.origin_global(:);
            parent_orientation_global = parsed_refframes{parID}.orientation_global;
        end

        parsed_refframes{idx}.orientation_global = parent_orientation_global*parsed_refframes{idx}.orientation;
        parsed_refframes{idx}.origin_global      = (parent_orientation_global\parsed_refframes{idx}.origin(:)+parent_origin_global(:))';
    end

    %% Add node positions to matlab adapter object
    for i = 1:length(parsed_refframes)
        frame_orientation_global  = parsed_refframes{i}.orientation_global;
        frame_origin_global       = parsed_refframes{i}.origin_global(:);

        for j = 1:length(parsed_refframes{i}.node_incl)
            node                = parsed_refframes{i}.node_incl(j);
            node_position_local = parsed_refframes{i}.node_pos(j,:)';

            obj.init_cond((node-1)*obj.dim*2+1:(node-1)*obj.dim*2+obj.dim) = frame_orientation_global\node_position_local+frame_origin_global;
            obj.pos((node-1)*obj.dim*2+1:(node-1)*obj.dim*2+obj.dim,1)     = obj.init_cond((node-1)*obj.dim*2+1:(node-1)*obj.dim*2+obj.dim);
        end
    end

    %% Create a table based on id_vect
    reference_frame_table = [];
    for i = 1:length(id_vect)
        idx                   = id_vect(i);
        reference_frame_table = [reference_frame_table;struct2table(parsed_refframes{idx},'AsArray',true)];
    end

    reference_frame_table = movevars(reference_frame_table, {'ref_tag','parent_tag','origin','orientation','node_incl','is_prop','origin_global','orientation_global','node_pos','num_blades'},'Before',1);    

    %% Save reference frame table in matlab_adapter object
    obj.reference_frame_table = reference_frame_table;
    disp("Reference frame table successfully created and updated in " + inputname(1));
    obj.save_obj(true);

end
