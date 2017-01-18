function y = detrend_sample(x, varargin)
% detrend_sample    Remove linear trends from `x` across samples
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     y = detrend_sample(x)
%     y = detrend_sample(x, OptionKey, OptionValue, ...)
%     y = detrend_sample(x, groups)
%     y = detrend_sample(x, groups, OptionKey, OptionValue, ...)
%
% Options:
%
% - Group   [vector] : Grouping vector
% - Verbose [on/off] : Enable verbose outputs or not (default = off)
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
                    {{'Group', 'vector', groups}, ...
                     {'Verbose', 'onoff', false}});
groups    = opt.Group;
isVerbose = opt.Verbose;

if isempty(groups)
    groups = ones(size(x, 1), 1);
end

%% Main
if isVerbose, fprintf('%s %s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Running', mfilename); end

grpList = unique(groups);
numGrp  = length(grpList);

y = nan(size(x));

for n = 1:numGrp
    if isVerbose, fprintf('%s %s %d\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Detrending Group', n); end;

    gInd      = groups == grpList(n);
    xInGrp    = x( gInd, : );
    numSample = size( xInGrp, 1);
    
    xDetrended = detrend( xInGrp, 'linear' );
    xDetrended = xDetrended + repmat( mean( xInGrp, 1 ), numSample, 1 );

    y(gInd, :) = xDetrended;

    clear xDetrended;
end

if isVerbose, fprintf('%s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Done'); end;
