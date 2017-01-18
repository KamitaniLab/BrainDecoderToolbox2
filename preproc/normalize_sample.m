function y = normalize_sample(x, varargin)
% normalize_sample    Normalize `x` within samples
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     y = normalize_sample(x)
%     y = normalize_sample(x, OptionKey, OptionValue, ...)
%     y = normalize_sample(x, groups)
%     y = normalize_sample(x, groups, OptionKey, OptionValue, ...)
%
% Options:
%
% - Group         [vector] : Grouping vector
% - Mode          [string] : Normalization mode ('PercentSignalChange', 'Zscore',
%                            'DivideMean', or 'SubtractMean')
% - Baseline      [vector] : Baseline index (default is 'all samples')
% - ZeroThreshold [scalar] : Zero threshold (default = 1)
% - Verbose       [on/off] : Enable verbose outputs or not (default = false)
%


%% Parameters
if mod(nargin, 2) == 1
    groups = [];
    optArgs = varargin;
else
    groups = varargin{1};
    if length(varargin) > 1
        optArgs = {varargin{2:end}};
    else
        optArgs = {};
    end
end

opt = bdt_getoption(optArgs, ...
                    {{'Group',         'vector', groups}, ...
                     {'Mode',          'string', 'PercentSignalChange'}, ...
                     {'Baseline',      'vector', ones(size(x, 1), 1)  }, ...
                     {'ZeroThreshold', 'scalar', 1                    }, ...
                     {'Verbose',       'onoff',  false                }});

groups         = opt.Group;
norm_mode      = opt.Mode;
baseline       = opt.Baseline;
zero_threshold = opt.ZeroThreshold;
isVerbose      = opt.Verbose;

if isempty(groups)
    groups = ones(size(x, 1), 1);
end

%% Main
if isVerbose, fprintf('%s %s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Running', mfilename); end

% Data settings
grpList = unique(groups);
numGrp  = length(grpList);

y = nan(size(x));

% Normalization
for n = 1:length(grpList)
    if isVerbose, fprintf('%s %s %d\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Normalizing samples Group', n); end;

    gInd      = groups == grpList(n);
    xInGrp    = x( gInd, : );
    numSample = size( xInGrp, 1);

    bInd = baseline & gInd; % Baseline index in the current group
    
    % Get the baseline
    bMat = repmat( mean( x(bInd, :),    1 ), numSample, 1 );
    bSd  = repmat( std(  x(bInd, :), 0, 1 ), numSample, 1 );

    switch norm_mode
      case 'PercentSignalChange'
        xInGrp = 100 * ( xInGrp - bMat ) ./ bMat;
      case 'Zscore'
        xInGrp = (xInGrp - bMat) ./ bSd;
      case 'DivideMean'
        xInGrp = 100 * xInGrp ./ bMat;
      case 'SubtractMean'
        xInGrp = xInGrp - bMat;
      otherwise
        error('normalize_sample:UnknownNormMode', ...
              sprintf('Unknwon normalization mode: %s', norm_mode));
    end
    
    y(gInd, :) = xInGrp;

    clear xInGrp;
end

if isVerbose, fprintf('%s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Done'); end;
