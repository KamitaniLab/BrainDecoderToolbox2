function [dataSet, metaData] = cat_dataset(varargin)
% cat_dataset    Concat multiple dataSet and metaData
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     [dataSet, metaData] = cat_dataset(dataSet1, metaData1, dataSet2, metaData2)
%     [dataSet, metaData] = cat_dataset(dataSet1, metaData1, dataSet2, metaData2, dataSet3, metaData3, ...)
%     [dataSet, metaData] = cat_dataset(dataSet1, metaData1, dataSet2, metaData2, 'IncrementColumn', 'Column_1')
%     [dataSet, metaData] = cat_dataset(dataSet1, metaData1, dataSet2, metaData2, 'IncrementColumn', {'Column_1', 'Column_2'})
%


%% Input processing
incCol = {};
incColLastValue = {};

if mod(nargin, 2) ~= 0
    error('cat_dataset:Invalid arguments', ...
          'The arguments should be dataSet-metaData pairs or option pairs (''Key'' and ''value'')');
else
    numInputPair = nargin / 2;
end

c = 1; % Counter for dat (dataSet+metaData)

for n = 1:numInputPair
    ind0 = (n - 1) * 2 + 1; % Index of the head of an input pair
    ind1 = (n - 1) * 2 + 2; % Index of the tail of an input pair

    if ischar(varargin{ind0})
        % The current input pair is an option key-value pair
        if isequal(varargin{ind0}, 'IncrementColumn')
            if iscell(varargin{ind1})
                for t = 1:length(varargin{ind1})
                    incCol = { incCol{:}, varargin{ind1}{t} };
                    incColLastValue = { incColLastValue{:}, 0 };
                end
            else
                incCol = { incCol{:}, varargin{ind1} };
                incColLastValue = { incColLastValue{:}, 0 };
            end
        end
    else
        dat(c).dataSet = varargin{ind0};
        dat(c).metaData = varargin{ind1};
        c = c + 1;
    end
end


%% Concat data
[dataSet, metaData] = initialize_dataset();

for n = 1:length(dat)

    if isempty(dat(n).dataSet)
        continue;
    end
    
    % Integrate metaData
    if isempty(metaData)
        metaData = dat(n).metaData;
    else
        if ~issamemetadata(metaData, dat(n).metaData)
            error('cat_dataset:MetaDataInconsistent', ...
                  'metaData are inconsistent');
        end
    end

    % Increment specified column values
    for c = 1:length(incCol)
        incColInd = get_metadata(metaData, incCol{c}, 'AsIndex', true);

        dat(n).dataSet(:, incColInd) = dat(n).dataSet(:, incColInd) + incColLastValue{c};
        incColLastValue{c} = dat(n).dataSet(end, incColInd);
    end

    % Concat dataSet
    dataSet = [dataSet; dat(n).dataSet];
end
