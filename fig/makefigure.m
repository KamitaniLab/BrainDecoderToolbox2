function h = makefigure(varargin)
% makefigure    Create a custom figure
%
% This file is a part of BrainDecoderToolbox2.
%
% Options:
%
% - fullscreen : Create a full-screen figure
% - hide       : Do not show the figure
%

%% Figure settings
isFullscreen = false;
isHide = false;

%% Parse options
for n = 1:nargin
    if ~ischar(varargin{n})
        error('Option should be a string');
    end

    switch varargin{n}
      case 'fullscreen'
        isFullscreen = true;
      case 'hide'
        isHide = true;
      otherwise
        warning('Unknown option %s', varargin{n})
    end
end

%% Create a figure
h = figure();

if isFullscreen
    set(h, 'Units', 'normalized', ...
           'Position', [0, 0, 1, 1]);
end

if isHide
    set(h, 'Visible', 'off');
end
