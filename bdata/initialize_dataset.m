function [dataSet, metaData] = initialize_dataset()
% initialize_dataset    Returns empty `dataSet` and `metaData`
%
% This function is obsoleted and kept for backward compatibility.
% Please use `init_bdata` instead.
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     [dataSet, metaData] = initialize_dataset()
%

[dataSet, metaData] = init_bdata();
