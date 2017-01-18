function dirList = getdirs(dirPath)
% getdirs    Get a list of directories
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - dirPath : Path to a directory
%
% Outputs:
%
% - dirList : A list of directories in `dirPath`
%

dirList = {};

ds = dir(dirPath);

c = 0;
for i = 1:length(ds)
    if ~exist(fullfile(dirPath, ds(i).name), 'dir')
        continue
    end

    if isequal(ds(i).name, '.') || isequal(ds(i).name, '..')
        continue
    end

    c = c + 1;
    dirList{c} = fullfile(dirPath, ds(i).name);
end
