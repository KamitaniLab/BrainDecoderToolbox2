function [y, varargout] = shift_sample(x, varargin)
% shift_sample    Shift samples
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     y = shift_sample(x, 'ShiftSize', n)
%     y = shift_sample(x, 'Group', groups, 'ShiftSize', n)
%     [y, ind] = shift_sample(x, 'ShiftSize', n)
%     [y, ind] = shift_sample(x, 'Group', groups, 'ShiftSize', n)
%
% Options:
%
% - Group     [vector] : Grouping vector
% - ShiftSize [scalar] : Sample shift size (default = 1)
% - Companion [cell]   : Array of companion data
% - Verbose   [on/off] : Enable verbose outputs or not (default = off)
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
                     {'ShiftSize', 'scalar', 1     }, ...
                     {'Verbose',   'onoff',  false }});

groups    = opt.Group;
compData  = opt.Companion;
shiftSize = opt.ShiftSize;
isVerbose = opt.Verbose;

if isempty(groups)
    groups = ones(size(x, 1), 1);
end

retComp = ~isempty(compData);


%% Main
if isVerbose, fprintf('%s %s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Running', mfilename); end

% Data settings
grpList = unique(groups);
numGrp  = length(grpList);

% Index for data to be removed
indDel    = [];
indDelRev = [];

% Shift data
for n = 1:numGrp
    if isVerbose, fprintf('%s %s %d\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Shifting data Group', n); end;

    gInd = find( groups == grpList(n) );

    beginInd = gInd(1);
    endInd   = gInd(end);

    if shiftSize > 0
        indDel = [ indDel, beginInd:(beginInd + shiftSize - 1) ];
        indDelRev = [ indDelRev, (endInd - shiftSize + 1):endInd ];
    elseif shiftSize < 0
        indDel = [ indDel, (endInd + shiftSize + 1):endInd ];
        indDelRev = [ indDelRev, beginInd:(beginInd - shiftSize - 1) ];
    else
        indDel = [ indDel ];
    end
end

% Output settings
indMap = [ 1:size(x, 1) ]';
indMap(indDelRev) = [];
x(indDel, :) = [];
y = x;

if retComp
    for i = 1:length(compData)
        compData{i} = compData{i}(indMap, :);
    end

    varargout = compData;
else
    varargout{1} = indMap;
end

if isVerbose, fprintf('%s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Done'); end;
