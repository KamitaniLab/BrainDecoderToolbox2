function metaData = add_metadata(metaData, key, description, value, attribute)
% add_metadata    Add meta data
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     metaData = add_metadata(metaData, key, description, value)
%     metaData = add_metadata(metaData, key, description, value, attribute)
%
% Inputs:
%
% - metaData    : Metadata structure
% - key         : Key of metadata
% - description : Description of metadata
% - value       : Value of metadata
% - attribute   : Key of metadata specifying data attribute (otpional)
%
% Outputs:
%
% - metaData : Metadata structure
%
% Notes:
%
% - `add_metadata` initializes a new meta data structure if `NaN` is given in
%   `metaData` or given `metaData` is empty
% - `add_metadata` overwrites meta-data if `key` already exists in
%   `metaData.key`
%

warning('off', 'backtrace');
warning('off', 'verbose');

% Check input
if isempty(metaData) || (~isstruct(metaData) && isnan(metaData))
    clear metaData;
    metaData.key         = {};
    metaData.description = {};
    metaData.value       = [];
end

if ~ischar(key)
    error('add_metadata:InvalideInputKey', ...
          '''key'' should be a string');
end

if ~ischar(description)
    error('add_metadata:InvalideInputDescription', ...
          '''description'' should be a string');
end

if ~isvector(value)
    error('add_metadata:InvalideInputValue', ...
          '''value'' should be a vector');
end

if ~exist('attribute', 'var')
    attr_ind = true(1, size(metaData.value, 2));
elseif ischar(attribute)
    attr_ind = get_metadata(metaData, attribute, 'AsIndex', true);
elseif isvector(attribute) && islogical(attribute)
    attr_ind = attribute;
else
    error('add_metadata:InvalideInputAttribute', ...
          '''attribute'' should be a string or a logical vector');
end

%% Main

if isempty(metaData.key)
    % Init metaData
    metaData.key{1}         = key;
    metaData.description{1} = description;
    metaData.value          = value;
    return;
end

ind_exist = strcmp( key, metaData.key );

if sum(ind_exist) == 0
    % Add metaData
    ind = size(metaData.value, 1) + 1;

    newMetaDataValue = nan(1, size(metaData.value, 2));
    newMetaDataValue(attr_ind) = value;
elseif sum(ind_exist) == 1
    % Overwrite metaData
    ind = ind_exist;

    newMetaDataValue = metaData.value(ind, :);
    value_exist      = metaData.value(ind, :);
    newMetaDataValue(attr_ind) = value;

    metaData.value(ind, attr_ind)  = value;

    warning('add_metadata:OverwriteMetaData', ...
            '''%s'' will be overwritten', key);

    fprintf('New meta-data value:\n');
    fprintf('\t%f', newMetaDataValue);
    fprintf('\n');
    
    fprintf('Existing meta-data value:\n');
    fprintf('\t%f', value_exist);
    fprintf('\n');
else
    % Multiple meta-data overwrite is not supported yet
    error('add_metadata:HitMultipleMetaData', ...
          '''%s'' hits more than two meta-data\n', key);
end

metaData.key{ind}         = key;
metaData.description{ind} = description;
metaData.value(ind, :)    = newMetaDataValue;

