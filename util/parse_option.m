function optList = parse_option(optStr)
% parse_option    Parse an option srting and return an option list as a cell array
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     optList = parse_option(optStr)
%
% Example:
%
%     >> parse_option('-a -b')
%     
%     ans = 
%     
%         '-a'    '-b'
%

if ~ischar(optStr)
    error('parse_option:InvalidInput', ...
          'The input should be a string');
end

optList = {};

if isempty(optStr)
    return;
end

delInd = strfind(optStr, ' ');

if isempty(delInd)
    optList{1} = optStr;
else
    optIndBegin = [ 1, delInd(1:end) + 1 ];
    optIndEnd   = [ delInd - 1, length(optStr) ];

    for n = 1:length(delInd)+1
        optInd = optIndBegin(n):optIndEnd(n);

        optList{n} = optStr(optInd);
    end
end
