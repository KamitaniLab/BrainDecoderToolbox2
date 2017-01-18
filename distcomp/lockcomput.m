function lockFile = lockcomput(cid, lockDir)
% lockcomput    Lock computation specified by `cid`
%
% This file is a part of BrainDecoderToolbox2.
%
% Input:
%
% - cid     : Computation ID [string]
% - lockDir : Directory keeping lock files (optional) [string]
%
% Output:
%
% - lockFIle : Name of the lock file [string]
%


if ~exist('lockDir', 'var')
    lockDir = './';
end

if ~exist(lockDir, 'dir')
    mkdir(lockDir);
end

lockFile = fullfile(lockDir, sprintf('%s.lock', cid));

fclose(fopen(lockFile, 'w'));
