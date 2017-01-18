function verboseoutput(s)
% verboseoutput    Output verbose messages
%
% `verboseoutput` displays a string `s` with timestamp in MATLAB command window.
%
% This file is a part of BrainDecoderToolbox2.
%

fprintf('%s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), s);
