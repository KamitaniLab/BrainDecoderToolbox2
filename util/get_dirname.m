function dname = get_dirname(dpath)
% get_dirname    Returns the name of directory in 'dpath'
%
% This file is a part of BrainDecoderToolbox2.
%

if ~exist(dpath, 'dir')
    warning([dpath ' is not a directory']);
end

if isequal(dpath(end), filesep)
    dpath = dpath(1:end-1);
end

[dPath, dBasename, dExt] = fileparts(dpath);

dname = [dBasename, dExt]
