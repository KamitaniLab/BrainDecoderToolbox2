function fileList = getfileindir(directory, ext)
% getfileindir    Get a list of file names in `dir`
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     fileList = getfileindir(directory, ext)
%
% Inputs:
%
% - directory : Path to a directory (string)
% - ext       : File extension (string)
%
% Outputs:
%
% - fileList : List of file names (N x 1 cell array)
%

files = dir(directory);

fileList = {};
c = 1;

for n = 1:length(files)
    if strcmp(files(n).name, '.') || strcmp(files(n).name, '..')
        continue;
    elseif regexp(files(n).name, sprintf('.*\\.%s$', ext))
        fileList{c, 1} = files(n).name;
        c = c + 1;
    else
        continue;
    end
end

