function strList = combcatfmt(fmt, varargin)
% combcatfmt    Returns a list of files
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     strList = combcatfmt(fmt, list0, list1, ...)
%
% Inputs:
%
% - fmt               : String format
% - list0, list1, ... : Cell arrays of strings or numbers
%
% Outputs:
%
% - strList : Cell array of strings
%


% TODO: add input check

strList = {};
c = 1;

if length(varargin) == 1
    for n = 1:length(varargin{1})
        if iscell(varargin{1})
            strList{c} = sprintf(fmt, varargin{1}{n});
        else
            strList{c} = sprintf(fmt, varargin{1}(n));
        end
        c = c + 1;
    end
else
    sInd = strfind(fmt, '%');

    fmtCar = fmt(1:sInd(2)-1);
    fmtCdr = fmt(sInd(2):end);
    
    subFileList = combcatfmt(fmtCdr, varargin{2:end});

    for n = 1:length(varargin{1})
    for m = 1:length(subFileList)
        if iscell(varargin{1})
            strList{c} = sprintf([fmtCar, '%s'], varargin{1}{n}, subFileList{m});
        else
            strList{c} = sprintf([fmtCar, '%s'], varargin{1}(n), subFileList{m});
        end
        c = c + 1;
    end
    end
end
