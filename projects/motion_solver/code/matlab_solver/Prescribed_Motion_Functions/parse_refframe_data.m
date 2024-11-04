
% Function to parse reference frame data
function parsed_refframe = parse_refframe_data(varargin)

    % Parse input data
    p = inputParser;
    
    addOptional(p, 'ref_tag', "defaultName");
    addOptional(p, 'is_prop', 0);
    addOptional(p, 'parent_tag', "0",  @(x) isstring(x) || isnumeric(x));
    addOptional(p, 'origin', [0 0 0]);
    addOptional(p, 'orientation', eye(3));
    addOptional(p, 'node_incl', []);
    addOptional(p, 'origin_global', []);
    addOptional(p, 'orientation_global', []);
    addOptional(p, 'node_pos',[]);
    addOptional(p, 'num_blades',[]);


    parse(p,varargin{:});

    parsed_refframe = p.Results;
    parsed_refframe.ref_tag = string(parsed_refframe.ref_tag{1});
    parsed_refframe.node_incl = parsed_refframe.node_incl(:);
end
