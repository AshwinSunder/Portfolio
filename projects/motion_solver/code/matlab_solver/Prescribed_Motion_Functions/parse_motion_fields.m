
% Parse motion fields 
function field_parsed_motion = parse_motion_fields(varargin)

    p = inputParser;
    p.KeepUnmatched = true;

    addOptional(p,"ref_frame","0");
    addOptional(p,"mot_mode","");
    addOptional(p,"mot_type","");
    addOptional(p,"mot_axis",[0 0 0]);
    addOptional(p,"mot_data",[]);

    parse(p,varargin{:});

    field_parsed_motion = p.Results;
end
