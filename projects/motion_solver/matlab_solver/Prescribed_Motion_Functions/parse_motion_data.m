
% Parse motion data 
function par = parse_motion_data(motion_data,name_val_pair)

    p = inputParser;
    p.KeepUnmatched = true;

    for i = size(name_val_pair,1):-1:1
        addOptional(p,name_val_pair{i,1},name_val_pair{i,2}); % name_val_pair is in the format: {fieldname1,defaultval1;fieldname2;defaultval2; ...}
    end
    
    parse(p, motion_data);

    par = p.Results;
end
