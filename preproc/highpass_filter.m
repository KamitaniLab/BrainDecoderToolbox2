function y = highpass_filter(x, varargin)
% highpass_filter    Apply high-pass filter (Butterworth filter) to `x`
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     y = highpass_filter(x)
%     y = highpass_filter(x, OptionKey, OptionValue, ...)
%     y = highpass_filter(x, groups)
%     y = highpass_filter(x, groups, OptionKey, OptionValue, ...)
%
% Options:
%
% - Group      [vector] : Grouping vector
% - CutOff     [scalar] : Cut-off frequency in Hz (default = 0.01)
% - SampleFreq [scalar] : Sampling frequency in Hz (default = 1)
% - Order      [scalar] : Order of Butterworth filter (default = 4)
% - KeepDc     [on/off] : Keep DC component (mean of the signals) or not (default = off)
% - Verbose    [on/off] : Enable verbose outputs or not (default = off)
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
                     {'CutOff',        'scalar', 0.01 }, ...
                     {'SampleFreq',    'scalar', 1    }, ...
                     {'Order',         'scalar', 4    }, ...
                     {'KeepDc',        'onoff',  false}, ...
                     {'SpmFilter',     'onoff',  false}, ...
                     {'LinearDetrend', 'onoff',  false}, ...
                     {'Verbose',       'onoff',  false}});

groups     = opt.Group;
cutOffFreq = opt.CutOff;     % [Hz]
sampleFreq = opt.SampleFreq; % [Hz]
order      = opt.Order;
keepDc     = opt.KeepDc;
isVerbose  = opt.Verbose;
isSpmFilter = opt.SpmFilter;
doDetrend   = opt.LinearDetrend;

if isempty(groups)
    groups = ones(size(x, 1), 1);
end

%% Main
if isVerbose, fprintf('%s %s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Running', mfilename); end

nf    = sampleFreq / 2;
wn    = cutOffFreq / nf;
dt    = 1 / sampleFreq;

grpList = unique(groups);
numGrp  = length(grpList);

for n = 1:numGrp
    if isVerbose, fprintf('%s %s %d\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Applying high-pass filter to Group', n); end;

    gInd   = groups == grpList(n);
    xInGrp = x( gInd, : );

    if isSpmFilter
        % High-pass filter with spm_filter
        if doDetrend
            x(gInd, :) = detrend(xInGrp);
        end

        kc{n}.row = min(find(gInd)):max(find(gInd)); % Group index
        kc{n}.HParam = 1 / cutOffFreq; % Cut-off should be [s], not [Hz]
        kc{n}.RT = dt;

        dimension = length(kc{n}.row);
        order = fix( 2 * (dimension * kc{n}.RT) / kc{n}.HParam + 1 );
        x0 = spm_dctmtx(dimension, order);
        kc{n}.x0 = x0(:, 2:end);

    else
        % Butterworth filter in Matlab
        if keepDc
            dc = repmat(mean(xInGrp, 1), size(xInGrp, 1), 1);
        else
            dc = 0;
        end
    
        [b, a] = butter(order, wn, 'high'); 
        y(gInd, :) = dc + filtfilt(b, a, xInGrp);
    end

end

if isSpmFilter
    k = cell2mat(kc);
    k = spm_filter(k);
    y = spm_filter(k, x);
end

if isVerbose, fprintf('%s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Done'); end;
