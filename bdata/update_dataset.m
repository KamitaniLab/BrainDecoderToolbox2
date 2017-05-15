function [dataSet, metaData] = update_dataset(dataSet, metaData, varargin)
% update_dataset    Updates dataSet
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     [dataSet, metaData] = update_dataset(dataSet, metaData, key, newdata, ...)
%
% Inputs:
%
% - dataSet, metaData [bdata]  : BrainDecoderToolbox2 data
% - key               [str]    : Metadata key of updated data
% - newdata           [matrix] : New data
%
% Outputs:
%
% - dataSet, metaData [bdata] : BrainDecoderToolbox2 data
%

colSize = size(dataSet, 2);
newSmpSize = size(varargin{2}, 1);

newdataset = zeros(newSmpSize, colSize);

c = 1;
while length(varargin) > c
    key = varargin{c};
    newdat = varargin{c + 1};

    [olddat, ind] = get_dataset(dataSet, metaData, key);

    if ~isequal(size(olddat, 2), size(newdat, 2))
        error('Modification of column size is not supported.');
    end

    if ~isequal(size(newdat, 1), newSmpSize)
        error('Sample size inconsistent.');
    end
    
    newdataset(:, ind) = newdat;
    
    c = c + 2;
end

dataSet = newdataset;
metaData = metaData;
