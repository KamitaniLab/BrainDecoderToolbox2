function strList = combcat(varargin)
% combcat    Combine and cat input strings
%
% This file is a part of BrainDecoderToolbox2.
%

for n = 1:nargin
    if ~iscell(varargin{n})
        varargin{n} = { varargin{n} };
    end
end

if nargin == 1
    for n = 1:length(varargin{1});
        strList{n} = varargin{1}{n};
    end
else
    sList = combcat(varargin{2:end});
    c = 1;
    for n = 1:length(varargin{1});
        for t = 1:length(sList)
        strList{c} = [ varargin{1}{n}, sList{t} ];
        c = c + 1;
        end
    end
end
