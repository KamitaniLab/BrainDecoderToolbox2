function isLocked = islocked(cid, lockDir)
% islocked    Return 'true' if computation `cid` is locked
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
% - isLocked : True if the computation is locked [Logical]
%


if ~exist('lockDir', 'var')
    lockDir = './';
end

lockFile = fullfile(lockDir, sprintf('%s.lock', cid));

if exist(lockFile, 'file')
    % Analysis is already running
    isLocked = true;
else
    % Create a lock file
    isLocked = false;
end
