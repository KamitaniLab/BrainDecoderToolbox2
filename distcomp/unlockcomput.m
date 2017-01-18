function lockFile = unlockcomput(cid, lockDir)
% unlockcomput    Unlock computation specified by `cid`
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

lockFile = fullfile(lockDir, sprintf('%s.lock', cid));

delete(lockFile);
