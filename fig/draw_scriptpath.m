function draw_scriptpath(h)
% drawscriptpath    Draw path to the script in the figure.
%
% This file is a part of BrainDecoderToolbox2.
%
% Input:
%
% - h : Figure handle (optional)
%

if ~exist('h')
    h = gcf;
end

[st, ind] = dbstack('-completenames');
if length(st) == 1
    scriptpath = '<Directly called>';
else
    scriptpath = st(end).file;
end

figtitle(h, scriptpath, 'bottom');
