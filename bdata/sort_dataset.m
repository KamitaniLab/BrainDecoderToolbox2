function [dataSet, metaData] = sort_dataset(dataSet, metaData, sortKey)
% sort_dataset    Sort `dataSet` by `sortKey`
%
% This file is a part of BrainDecoderToolbox2
%

sortValue = get_dataset(dataSet, metaData, sortKey);

[stv, ind] = sort(sortValue);
dataSet = dataSet(ind, :);
