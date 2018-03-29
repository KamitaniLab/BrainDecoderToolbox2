function y = regressout(x, varargin)
% regressout    Run regress-out denoising
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     y = regressout(x, 'Regressor', matrix, ...)
%
% Options:
%
% - Group         [M-d vector]   : Grouping vector
% - Regressor     [M x R matrix] : Regressor matrix
% - RemoveDc      [on/off]       : Remove DC components or not (default = off)
% - LinearDetrend [on/off]       : Run linear detrending or not (default = off)
% - Verbose       [on/off]       : Output verbose messages or not (default = off)
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
                     {'Regressor',     'matrix', []   }, ...
                     {'RemoveDc',      'onoff',  false}, ...
                     {'LinearDetrend', 'onoff',  false}, ...
                     {'Verbose',       'onoff',  false}});

groups    = opt.Group;
regressor = opt.Regressor;
linearDet = opt.LinearDetrend;
removeDc  = opt.RemoveDc;
isVerbose = opt.Verbose;

if isempty(groups)
    groups = ones(size(x, 1), 1);
end


%% Main
if isVerbose, fprintf('%s %s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Running', mfilename); end

% Check input size
nsample = size(x, 1);
lengroup = length(groups);
if nsample ~= lengroup
    error('Num of samples in `x` (%d) and length of the group vector (%d) mismatch', nsample, lengroup);
end

if ~isempty(regressor)
    lenreg = size(regressor, 1);
    if nsample ~= lenreg
        error('Num of samples in `x` (%d) and length of the regressor (%d) mismatch', nsample, lenreg);
    end
end

grpList = unique(groups);
numGrp  = length(grpList);

y = nan(size(x));

for n = 1:numGrp
    gind    = groups == grpList(n);
    xgrp    = x(gind, :);
    numSample = size(xgrp, 1);

    if ~isempty(regressor)
        regresgrp = regressor(gind, :);
    else
        regresgrp = [];
    end

    dcComp = ones(numSample, 1);

    if linearDet
        lineTrend = [1:numSample]' / numSample;
    else
        lineTrend = [];
    end

    regmat = [dcComp, lineTrend, regresgrp];

    if ~isempty(regmat)
        w = (regmat' * regmat) \ (regmat' * xgrp);

        y(gind, :) = xgrp - regmat * w;

        % Put back mean of the input when 'RemoveDC' is 'off', instead of
        % discarding DC component regressor (to avoid multi-colinearity;
        % suggested by Tomoyasu Horikawa).
        if ~removeDc
            dc = mean(xgrp, 1);
            y(gind, :) = y(gind, :) + dc(ones(size(xgrp,1), 1), :);
        end

    else
        % Do nothings
        y(gind, :) = xgrp;
    end
end

if isVerbose, fprintf('%s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Done'); end
