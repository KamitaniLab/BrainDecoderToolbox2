function [y, varargout] = average_sample(x, varargin)
% average_sample    Average `x` with samples
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     y = average_sample(x)
%     y = average_sample(x, OptionKey, OptionValue, ...)
%     y = average_sample(x, groups)
%     y = average_sample(x, groups, OptionKey, OptionValue, ...)
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
                    {{'Group',     'vector', groups}, ...
                     {'Companion', 'cell',   {}    }, ...
                     {'Verbose',   'onoff',  false}});
groups    = opt.Group;
compData  = opt.Companion;
isVerbose = opt.Verbose;

if isempty(groups)
    groups = ones(size(x, 1), 1);
end

retComp = ~isempty(compData);


%% Main
if isVerbose, fprintf('%s %s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Running', mfilename); end

grpList = unique(groups);
numGrp  = length(grpList);

y      = nan( numGrp, size(x, 2) );
indMap = [];

for n = 1:numGrp
    if isVerbose, fprintf('%s %s %d\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Averaging Group', n); end;

    gInd = groups == grpList(n);
    y(n, :) = mean( x( gInd, : ), 1 );

    ind = find(gInd);
    indMap = [ indMap; ind(1) ];
end

if retComp
    for i = 1:length(compData)
        compData{i} = compData{i}(indMap, :);
    end

    varargout = compData;
else
    varargout{1} = indMap;
end

if isVerbose, fprintf('%s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Done'); end;
