function [data, fileList] = load_matfiles_fast(dpath)
% load_matfiles_fast    Load data from Mat files in `dpath` directory using `matfile`.
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - dpath   : Path to directory containing Mat files.
%
% Outputs:
%
% - data     : Cell array of mat-file objects (loaded by matfile).
% - fileList : Cell array of loaded files.
%

files = dir(dpath);

fileList = {};
data = {};

for i = 1:length(files)
    if isequal(files(i).name, '.') || isequal(files(i).name, '..')
        continue;
    end

    fpath = fullfile(dpath, files(i).name);
    [pathstr, name, ext] = fileparts(fpath);

    if ~isequal(ext, '.mat');
        continue;
    end

    data{end + 1, 1} = matfile(fpath);
    fileList{end + 1, 1} = files(i).name;
end
