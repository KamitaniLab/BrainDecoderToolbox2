function backupFile = backupscript();
% backupscript    Backup current running script
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% None
%
% Outputs:
%
% - backupFile : Full path of the backup file
%

dateStr = datestr(now, 'YYYYmmddTHHMMSS');

% Get the file name calling me
[st, ind] = dbstack('-completenames');
scriptFileName = st(ind + 1).file;

[scriptPath, scriptBaseName, scriptExt] = fileparts(scriptFileName);

srcFileName = scriptFileName
dstFileName = fullfile(scriptPath, [scriptBaseName, '_', dateStr, scriptExt])

% Backup the script
copyfile(srcFileName, dstFileName);

backupFile = dstFileName;
