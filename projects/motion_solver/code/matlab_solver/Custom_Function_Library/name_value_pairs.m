
% Function to create name-value pairs
function nvp = name_value_pairs(varargin)

    if isempty(varargin) || (iscell(varargin) && mod(length(varargin),2)==1)
        nvp={};
        return

    elseif length(varargin) == 2 && iscell(varargin{1}) && iscell(varargin{2})

        nvp(:,1) = varargin{1}(:);
        nvp(:,2) = varargin{2}(:);
        return

    else
        nvp = cell(length(varargin(~cellfun('isempty',varargin(:,1)))),2);
        j=1;
    
        for i=1:2:length(varargin)
    
            if isa(varargin{i},'char')
                nvp(j,:) = [varargin{i} varargin{i+1}];
                j=j+1;
    
            else         
                nvp={};
                return
            end
        end      
    end
end
