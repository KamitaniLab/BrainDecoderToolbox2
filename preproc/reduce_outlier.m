function [y, varargout]  = reduce_outlier(x, varargin)
% reduce_outlier    Reduce outlier values from `x`
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     y = reduce_outlier(x)
%     y = reduce_outlier(x, OptionKey, OptionValue, ...)
%     [y, ind] = reduce_outlier(x)
%     [y, ind] = reduce_outlier(x, OptionKey, OptionValue, ...)
%
%     % Old arguments style
%     y = reduce_outlier(x, groups)
%     y = reduce_outlier(x, groups, OptionKey, OptionValue, ...)
%     [y, ind] = reduce_outlier(x, groups)
%     [y, ind] = reduce_outlier(x, groups, OptionKey, OptionValue, ...)
%
% Inputs:
%
% - x [matrix] : Input data matrix
%
% Outputs:
%
% - y   [matrix] : Output data matrix
% - ind [vector] : Either index of removed rows/columns or index map
%
% Options:
%
% - Group        [vector] : Grouping vector
% - ByStd        [on/off] : Reduce outliers based on SD or not (default: on)
% - ByMaxMin     [on/off] : Reduce outliers based on max and min values or not (default: on)
% - Remove       [on/off] : Remove rows or columns containing outliers or not (default: off)
% - Dimension    [scalar] : Dimension of dataSet to calculate mean and std for the
%                           reduction (1: time/sample, 2: feature; default: 1)
% - NumIteration [scalar] : Num of iterations (default: 10)
% - StdThreshold [scalar] : STD threshold (default: 3)
% - Max          [scalar] : Max value (default: inf) 
% - Min          [scalar] : Min value (default: -inf)
% - IndexMap     [on/off] : Returns index map or not (default: off)
% - Verbose      [on/off] : Enable verbose outputs or not (default: off)
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
                    {{'Group',        'vector', groups}, ...
                     {'Companion',    'cell',   {}    }, ...
                     {'ByStd',        'onoff',  true  }, ...
                     {'ByMaxMin',     'onoff',  true  }, ...
                     {'Remove',       'onoff',  false }, ...
                     {'Dimension',    'scalar', 1     }, ...
                     {'NumIteration', 'scalar', 10    }, ...
                     {'StdThreshold', 'scalar', 3     }, ...
                     {'Max',          'scalar', inf   }, ...
                     {'Min',          'scalar', -inf  }, ...
                     {'IndexMap',     'onoff',  false }, ...
                     {'Verbose',      'onoff',  false }});

groups        = opt.Group;
compData      = opt.Companion;
dim           = opt.Dimension;
reduce_std    = opt.ByStd;
reduce_lim    = opt.ByMaxMin;
do_remove     = opt.Remove;
num_itr       = opt.NumIteration;
std_threshold = opt.StdThreshold;
max_val       = opt.Max;
min_val       = opt.Min;
isVerbose     = opt.Verbose;
indexmap      = opt.IndexMap;

if isempty(groups)
    groups = ones(size(x, 1), 1);
end

retComp = ~isempty(compData);


%% Main
if isVerbose, fprintf('%s %s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Running', mfilename); end

% Data settings
grpList  = unique(groups);
numGrp   = length(grpList);
nSample  = size(x, 1);
nFeature = size(x, 2);

% y: output data
y = nan(size(x));

% rd_ind: index of outliers
if dim == 1
    rd_ind = false(1, size(x, 2));
elseif dim == 2
    rd_ind = false(size(x, 1), 1);
end

% Reduce outliers
for n = 1:length(grpList)
    if isVerbose, fprintf('%s %s %d\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Reducing outliers Group', n); end;

    gInd   = groups == grpList(n);
    xInGrp = x( gInd, : );
    nSmp   = size(xInGrp, 1);

    outInd_up  = false(size(xInGrp));
    outInd_lw  = false(size(xInGrp));
    outInd_max = false(size(xInGrp));
    outInd_min = false(size(xInGrp));
    outInd     = false(size(xInGrp));
    
    % Reduce by STD
    if reduce_std
    for itr = 1:num_itr
        mu = mean(xInGrp, dim);
        sd = std(xInGrp, 0, dim);

        if dim == 1
            repind = ones(nSmp, 1);
            th = mu + sd * std_threshold;
            thup = th(repind, :);
            th = mu - sd * std_threshold;
            thlw = th(repind, :);
        elseif dim == 2
            repind = ones(1, nFeature);
            th = mu + sd * std_threshold;
            thup = th(:, repind);
            th = mu - sd * std_threshold;
            thlw = th(:, repind);
        else
            error('reduce_outlier:InvalidDimension', ...
                  sprintf('Invalid dimensiton: %d\n', dim));
        end            

        outInd_up = thup < xInGrp;
        outInd_lw = thlw > xInGrp;
        
        % Clip outliers
        xInGrp(outInd_up) = thup(outInd_up);
        xInGrp(outInd_lw) = thlw(outInd_lw);
    end
    end

    % Reduce by max-min
    if reduce_lim
        if max_val < inf
            outInd_max = xInGrp > max_val;
            xInGrp(outInd_max) = max_val;
        end
        if min_val > -inf
            outInd_min = xInGrp < min_val;
            xInGrp(outInd_min) = min_val;
        end
    end

    % Get reduced data index
    outInd = outInd_up | outInd_lw | outInd_max | outInd_min;

    if dim == 1
        rd_ind = rd_ind | sum(outInd, dim) >= 1;
    elseif dim == 2
        rd_ind(gInd) = rd_ind(gInd) | sum(outInd, dim) >= 1;
    end

    num_data = numel(xInGrp);
    num_out = length(find(outInd));

    % Disp info
    if isVerbose
        fprintf('%s %s: %d / %d (%.2f)\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
                'Num of outliers', num_out, num_data, 100 * (num_out / num_data));
    end
    
    % Update data
    y(gInd, :) = xInGrp;
    clear xInGrp;
end

% Remove outliers
if do_remove
    if dim == 1
        y(:, rd_ind) = [];
        num_rd = sum(rd_ind);
        fprintf('%s %s: %d\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
                'Removed columns: ', num_rd);
    elseif dim == 2
        y(rd_ind, :) = [];
        num_rd = sum(rd_ind);
        fprintf('%s %s: %d\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), ...
                'Removed rows: ', num_rd);
    end

    indRemoved = rd_ind;
else
    indRemoved = [];
end

if retComp
    % Returns companion data
    for i = 1:length(compData)
        if dim == 1
            compData{i}(:, indRemoved) = [];
        else
            compData{i}(indRemoved, :) = [];
        end
    end

    varargout = compData;
else
    if indexmap
        % Returns index map
        if dim == 1
            % Feature reduction
            indmap = 1:size(x, 2);
        elseif dim == 2
            % Sample reduction
            indmap = [1:size(x, 1)]';
        end

        indmap(indRemoved) = [];
        varargout{1} = indmap;
    else
        % Returns index for removed rows/columns
        varargout{1} = indRemoved;
    end
end


if isVerbose, fprintf('%s %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), 'Done'); end;
