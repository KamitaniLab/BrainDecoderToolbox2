function [dataSet, metaData] = drop_data(dataSet, metaData, expr)
% drop_data    Drops data from `dataSet` and `metaData`
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     [dataSet, metaData] = drop_data(dataSet, metaData, expr)
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
%     [dataSet, metaData] = drop_data(dataSet, metaData, 'ROI_A = 1')
%

[y, ind] = select_data(dataSet, metaData, expr);

dataSet(:, ind) = [];
metaData.value(:, ind) = [];
