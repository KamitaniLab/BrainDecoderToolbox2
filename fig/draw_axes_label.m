function draw_axes_label(axnames, xy, raw, varargin)
% draw_axes_label    Write x or y axis labels
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - axnames : axisnames
% - xy      : assign x axis == 1 or y axis == 2 (default == 1, x axis)
% - raw     : whether the label index is straightforwardly used or not
%             0 or range of axes
%
% Note:
%
% Originally developed as `axnames` by Tomoyasu Horikawa <horikawa-t@atr.jp> on 2010-06-02
%

if ~exist('xy','var') || isempty(xy)
    xy=1;
end
if ~exist('raw','var') || isempty(raw)
    raw=0;
end

if raw==0
    switch xy
        case 2
            set(gca,'YTickLabel',axnames,'YTick',1:length(axnames),varargin{:})
            ylim([0.5,length(axnames)+0.5])
        otherwise
            set(gca,'XTickLabel',axnames,'XTick',1:length(axnames),varargin{:})
            xlim([0.5,length(axnames)+0.5])
    end
else
    switch xy
        case 2
            set(gca,'YTickLabel',axnames,'YTick',raw,varargin{:})
        otherwise
            set(gca,'XTickLabel',axnames,'XTick',raw,varargin{:})
    end
end
