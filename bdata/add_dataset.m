function [dataSet, metaData] = add_dataset(dataSet, metaData, x, attribute, description)
% add_dataSet    Add `x` to `dataSet` with `attribute`
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     [dataSet, metaData] = add_dataset(dataSet, metaData, x, attribute)
%
% Inputs:
%
% - dataSet     : Dataset matrix
% - metaData    : Metadata structure
% - x           : Data to be added to `dataSet`
% - attribute   : Metadata key specifying the attribute of `x`
% - description : Metadata description (optional)
%
% Outputs:
%
% - dataSet  : Dataset matrix
% - metaData : Metadata structure
%

%% Check input

if ~exist('description', 'var')
    description = sprintf('1 = %s', attribute);
end

% Init metaData if `metaData` is empty
if isempty(metaData)
    clear metaData;
    metaData.key         = {};
    metaData.description = {};
    metaData.value       = [];
end

%% Add data to dataSet
try
    dataSet = [ dataSet, x ];
catch
    error('add_dataset:FailedToUpdateDataset', ...
          'Failed to add `x` to `dataSet`');
end

%% Add mete-data of data attribution
nNewFeat  = size(x, 2);
nFeature  = size(metaData.value, 2);
nMetaData = size(metaData.value, 1);

indKey = strcmp(metaData.key, attribute);

if sum(indKey) == 1
    % Update existing meta-data for data attribution

    newMetaData = nan(nMetaData, nNewFeat);
    newMetaData(indKey, :) = 1;
    
    metaData.value = [ metaData.value, newMetaData ];
elseif sum(indKey) == 0
    % Add new metadata for data attribution

    metaData.key{end+1} = attribute;
    metaData.description{end+1} = description;

    metaData.value = [ metaData.value,   nan(nMetaData, nNewFeat);
                       nan(1, nFeature), ones(1, nNewFeat) ];
else
    error('add_dataset:FailedToUpdateMetaData', ...
          'Fail to update `metaData`');
end
