function setupdir(dirPath)
% setupdir    Create `dirPath` is not exist
%
% This file is a part of BrainDecoderToolbox2.
%

if ~exist(dirPath, 'dir')
    mkdir(dirPath);
end;
