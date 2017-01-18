function savefigure(h, fileName, varargin)
% savefigure    Save the figure
%
% This file is a part of BrainDecoderToolbox2.
%

opt = bdt_getoption(varargin, ...
                    {{'Caption', 'char', ''}});

caption = opt.Caption;

[ filePath, fileBase, fileExt ] = fileparts(fileName);

if ~isempty(filePath) && ~exist(filePath, 'dir')
    mkdir(filePath);
end

switch fileExt
  case '.pdf'
    device = '-dpdf';
  case '.eps'
    device = '-depsc';
  case '.ps'
    device = '-dpsc';
  case '.tiff'
    device = '-dtiff';
  case '.png'
    device = '-dpng';
  case {'.jpeg', '.jpg'}
    device = '-djpeg';
  otherwise
    error('Unknown file type: %s', fileExt);
end

set(h, 'PaperType', 'a4', ...
       'PaperOrientation', 'landscape', ...
       'PaperUnits', 'normalized', ...
       'PaperPosition', [0, 0, 1, 1]);

if ~isempty(caption)
    figtitle(h, caption, 'bottom');
end

print(h, fileName, device);
