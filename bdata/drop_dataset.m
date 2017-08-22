function [dataSet, metaData] = drop_dataset(dataSet, metaData, expr)
% drop_dataset    Drops data from `dataSet` and `metaData`
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     [dataSet, metaData] = drop_dataset(dataSet, metaData, expr)
%
% Inputs:
%
% - dataSet, metaData [bdata] : BrainDecoderToolbox2 data
% - expr              [str]   : Expression specifying dropped data
%
% Outputs:
%
% - dataSet, metaData [bdata] : BrainDecoderToolbox2 data
%
% Examples:
%
%     % Remove data included in 'ROI_A' from `dataSet` and `metaData`
%     [dataSet, metaData] = drop_dataset(dataSet, metaData, 'ROI_A = 1')
%

[y, ind] = select_dataset(dataSet, metaData, expr);

dataSet(:, ind) = [];
metaData.value(:, ind) = [];
