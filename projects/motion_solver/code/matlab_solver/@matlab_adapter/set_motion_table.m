
% Function to set motion table
function motion_table = set_motion_table(obj,motionarray)
 %   Short Description
    %% Input
    %
    %
    %% Output
    %
    %

    %% Check if reference frames have been provided; if yes, check if all are structures
    assert(length(motionarray) >= 1 ,"No motion structures have been provided.");
    for i = 1:length(motionarray)
        assert(isstruct(motionarray{i}),"Motions have not been provided as structures.");
    end

    %% Parse required fields for each motion
    parsed_motions = cell(1,length(motionarray));
    for i = 1:length(motionarray)
        parsed_motions{i} = parse_motion_fields(motionarray{i});
    end

    %% Parse mot_data based on mot_type and/or mot_mode
    % Save user-accepted input fieldnames and default values in an array
    name_val.e = {"t0", obj.tstart; "tf", obj.tfinal; "freq",    0; "eigval",    0; "eigvec",    0; "mode",     1; "damp",   0};
    name_val.h = {"t0", obj.tstart; "tf", obj.tfinal; "amp",     0; "omega",     0; "phi",       0; "offset",   0; "lambda", 0};
    name_val.f = {"t0", obj.tstart; "tf", obj.tfinal; "arg_in", {}; "val_in",   {}; "arg_out",  {}; "val_out", {}; "func",  []};
    name_val.u = {"t0", obj.tstart; "tf", obj.tfinal; "vec",    []; "vec_type", ""; "vec_loc",  ""};
    name_val.c = {"t0", obj.tstart; "tf", obj.tfinal; "rate",    0; "lambda",    0}; 

    for i = 1:length(parsed_motions)
        if parsed_motions{i}.mot_type     == 'c'
            name_val_pair = name_val.c;
        elseif parsed_motions{i}.mot_type == 'h'
            name_val_pair = name_val.h;
        elseif parsed_motions{i}.mot_mode == 'e'
            name_val_pair = name_val.e;
        elseif parsed_motions{i}.mot_type == 'f' || parsed_motions{i}.mot_mode == 'f'
            name_val_pair = name_val.f;
        elseif parsed_motions{i}.mot_type == 'u' || parsed_motions{i}.mot_mode == 'u'
            name_val_pair = name_val.u;
        end
            parsed_motion_data = parse_motion_data(motionarray{i},name_val_pair);
            parsed_motions{i}.mot_data = {parsed_motion_data(:)};
    end

    %% Create a motion table from the parsed motion array
    motion_table = [];
    for i = 1:length(parsed_motions)
        motion_table = [motion_table;struct2table(parsed_motions{i})];
    end

    %% Reorder motion table based on parent-child relationships
    id_vect = [];
    for i = 1:height(obj.reference_frame_table)
        ref_tag = obj.reference_frame_table.ref_tag(i);
        id_vect = [id_vect;find(motion_table.ref_frame == ref_tag)];
    end
    
    motion_table = motion_table(id_vect,:);
    motion_table = movevars(motion_table,{'ref_frame','mot_mode','mot_type','mot_axis','mot_data'},'Before',1);

    %% Save motion table in matlab_adapter object
    obj.motion_table = motion_table;
    disp("Motion table successfully created and updated in " + inputname(1));
    obj.save_obj(true);
    
end
