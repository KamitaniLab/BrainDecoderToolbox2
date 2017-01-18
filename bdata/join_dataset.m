function [dataSet, metadata] = join_dataset(dataSet0, metadata0, dataSet1, metadata1)
% join_dataset    Join two dataSets into a single dataSet
%
% This file is a part of BrainDecoderToolbox2.
%

% Join dataSets
dataSet = [dataSet0, dataSet1];

% Join metadatas
rowInd0 = [  true(1, size(dataSet0, 2)), false(1, size(dataSet1, 2)) ];
rowInd1 = [ false(1, size(dataSet0, 2)),  true(1, size(dataSet1, 2)) ];

metadata = struct('key', {}, ...
                  'description', {}, ...
                  'value', []);

for n = 1:length(metadata0.key)
    newMetadata = [ metadata0.value(n, :), nan(1, size(dataSet1, 2)) ];
    metadata = add_metadata(metadata, ...
                            metadata0.key{n}, ...
                            metadata0.description{n}, ...
                            newMetadata);
end
for n = 1:length(metadata1.key)
    newMetadata = metadata1.value(n, :);
    metadata = add_metadata(metadata, ...
                            metadata1.key{n}, ...
                            metadata1.description{n}, ...
                            newMetadata, ...
                            rowInd1);
end

