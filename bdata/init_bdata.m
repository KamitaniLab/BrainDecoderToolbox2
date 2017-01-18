function [dataSet, metaData] = init_bdata()
% init_bdata    Returns empty `dataSet` and `metaData`
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     [dataSet, metaData] = initialize_dataset()
%

dataSet  = [];
metaData = struct('key',         {}, ...
                  'description', {}, ...
                  'value',       []);
