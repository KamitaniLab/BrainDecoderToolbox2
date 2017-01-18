function value = get_metadata(metaData, key, varargin)
% get_metadata    Get meta data specified with 'key' from 'metaData'
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     value = get_metadata(metaData, key)
%     value = get_metadata(metaData, key, options)
%
% Inputs:
%
% - metaData : Metadata structure
% - key      : Key of metadata
% - options  : Key-value pairs of options
%
% Outputs:
%
% - value : Value of metadata specified by `key`
%
% Options:
%
% - AsIndex   : Return `value` as a logical vector (default: false)
% - RemoveNan : Remove NaN from `value' (default: false)
%
% Notes:
%
% - `get_metadata` returns an empty matrix if `key` does not hit to keys in
%   `metaDeta.key`
% - `get_metadata` returns a M x N matrix if `key` hits several (M) keys in
%   in `metaDeta.key` (N is the length of meta data)
%


%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off', 'backtrace');
warning('off', 'verbose');

%% Check input
keyType = whos('key');
switch keyType.class
  case 'cell'
    keyList = key;
  case 'char'
    keyList{1} = key;
  otherwise
    error('get_metadata:InvalideInputKey', ...
          '''key'' should be a string or a cell array');
end

if exist('opt', 'var') && ~ischar(opt)
    error('get_metadata:InvalideInputOption', ...
          '''opt'' should be a string');
end


%% Option settings
isLogicalIndex = false;
ignoreNan      = false;

if nargin == 3
    % Old stype option
    % This is kept for backward-compatibility
    warning('get_metadata:ObsoletedOptionsStyle', ...
            'You are using obsoleted style options. Please use key-value pairs instead.');

    opt_list = parse_option(varargin{1});

    if sum(strcmp(opt_list, 'as_index')) == 1, isLogicalIndex = true; end
    if sum(strcmp(opt_list, '-i')) == 1,       isLogicalIndex = true; end
    if sum(strcmp(opt_list, '-n')) == 1,       ignoreNan      = true; end
elseif nargin > 3
    % New style option (key-value pairs)
    if mod(length(varargin), 2) ~= 0
        error('get_metadata:InvalideInputOption', ...
              'Options should be specified by key-value pairs');
    end

    opt = bdt_getoption(varargin, ...
                        {{'AsIndex',   'onoff', false}, ...
                         {'RemoveNan', 'onoff', false}});

    isLogicalIndex = opt.AsIndex;
    ignoreNan = opt.RemoveNan;
end


%% Main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get metadata value for each key in keyList

valueList = {};

for m = 1:length(keyList)

    ckey = keyList{m};
    
    ind = strcmp(metaData.key, ckey);

    if sum(ind) == 1
        value = metaData.value(ind, :);
    elseif sum(ind) == 0
        warning('get_metadata:KeyNotFound', ...
                '''%s'' was not found in metaData', ckey);

        value = [];
    elseif sum(ind) > 1
        nInds = find(ind);
        for n = 1:length(nInds)
            value(n, :) = metaData.value(nInds(n), :);
        end
    else
        error('get_metadata:UnknownError', ...
              'Unknown error occured in get_metadata');
    end
    
    % Remove NaN
    if ignoreNan
        value(isnan(value)) = [];
    end

    valueList{m} = value;
end


%% Concat value list

value = [];

for n = 1:length(valueList)

    v = valueList{n};

    % TODO: Add length check of v

    value = [value; v];

    if isLogicalIndex
        value(isnan(value)) = 0;
        value = logical(value);
    end
end

