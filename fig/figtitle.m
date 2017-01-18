function htxt = figtitle(hfig, str, pos)
% figtitle    Draw title text on the figure
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - hfig : Figure handle
% - str  : Title string
% - pos  : Position of the title ('top' or 'bottom', default: 'top')
%
% Outputs:
%
% - htxt : Axis handle
%
% Note:
%
% This function is based on `suptitle` developed by Drea Thomas, John Cristion,
% and Mark Histed (suptitle.m,v 1.2 2004/03/13 22:17:47 histed Exp).
%

if ~exist('pos', 'var')
    pos = 'top';
end

if isequal(pos, 'top')
    titleypos = 0.98;
elseif isequal(pos, 'bottom')
    titleypos = 0.02;
else
    error('Unsupported title position');
end

fontSize = get(hfig, 'defaultaxesfontsize');

np = get(hfig, 'nextplot');
set(hfig, 'nextplot', 'add');

% Draw the title
ha = axes('Position', [0, 0, 1, 1], 'Visible', 'off', 'Tag', 'figtitle');
ht = text(0.5, titleypos, str, ...
          'Interpreter', 'none', ...
          'FontSize', fontSize, ...
          'HorizontalAlignment', 'center');

set(hfig, 'nextplot', np);
