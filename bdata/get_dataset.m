function [x, ind] = get_dataset(dataSet, metaData, key, value)
% get_dataset    Get data from `dataSet` specified by `key`
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     x = get_dataset(dataSet, metaData, key)
%     x = get_dataset(dataSet, metaData, key, value)
%     [x, ind] = get_dataset(dataSet, metaData, key)
%     [x, ind] = get_dataset(dataSet, metaData, key, value)
%
% Inputs:
%
% - dataSet  : Dataset matrix
% - metaData : Metadata structure
% - key      : Key of metadata specifying columns in `dataSet`
% - value    : Value of metadata specifying columns in `dataSet`
%              (optional, default: 1)
%
% Outputs:
%
% - x   : Matrix of columns selected by meta-data key-value from dataSet
% - ind : Index of selected columns in dataSet
%

if ~exist('value', 'var')
    value = 1;
end

metaData_value = get_metadata(metaData, key);

ind = metaData_value == value;

if sum(ind) == 0
    x = [];
else
    x = dataSet(:, ind);
end

