function doExist = checkfiles(fileList)
% checkfiles    Return true if all files in `fileList` exist
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - fileList : List of files to be checked [cell array or string]
%
% Output:
%
% - doExist : True if all files in `fileList` exist [logical]
%


if ~iscell(fileList) && ischar(fileList)
    fileList = {fileList};
end

doExist = true;

for n = 1:length(fileList)
    if ~exist(fileList{n}, 'file')
        doExist = false;
        break;
    end
end
