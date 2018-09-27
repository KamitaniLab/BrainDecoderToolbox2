function [data, fileList] = load_matfiles(dpath, varname)
% load_matfiles    Load data from Mat files in `dpath` directory.
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - dpath   : Path to directory containing Mat files.
% - varname : Name of variable to be loaded in the mat files.
%
% Outputs:
%
% - data     : Cell array of loaded data.
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

    dat = load(fpath);
    data{end + 1, 1} = dat.(varname);
    fileList{end + 1, 1} = files(i).name;
end
