function [dataSet, metaData] = add_design(dataSet, metaData, design)
% add_design    Adds experiment design information
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     [dataSet, metaData] = add_design(dataSet, metaData, design)
%
% Inputs:
%
% - dataSet [dataSet matrix]      : BrainDecoderToolbox2 dataset matrix
% - metaData [metaData structure] : BrainDecoderToolbox2 metadata structure
% - design [matrix]               : Experiment design matrix
%
% Outputs:
%
% - dataSet [dataSet matrix]      : BrainDecoderToolbox2 dataset matrix
% - metaData [metaData structure] : BrainDecoderToolbox2 metadata structure
%

volLen = size(dataSet, 1);

blockNum = nan(volLen, 1);
stimCode = nan(volLen, 1);

for i = 1:size(design, 1);
    blockInit = design(i, 1);
    blockLen  = design(i, 2);
    blockCode = design(i, 3);

    blockNum(blockInit:blockInit+blockLen-1) = i;
    stimCode(blockInit:blockInit+blockLen-1) = blockCode;

end

[dataSet, metaData] = add_dataset(dataSet, metaData, blockNum, 'Block');
[dataSet, metaData] = add_dataset(dataSet, metaData, stimCode, 'Label');
