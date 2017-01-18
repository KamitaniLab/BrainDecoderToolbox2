function isSame = issamemetadata(metaData1, metaData2);
% issamemetadata    Returns true if `metaData1` and `metaData2` are identical
%
% This file is a part of BrainDecoderToolbox2.
%

isSame = true;

if ~isequal(metaData1.key, metaData2.key)
    isSame = false;
    return;
end

if ~isequal(metaData1.description, metaData2.description)
    isSame = false;
    return;
end

% Convert NaN in metaData.value to 0
metaData1.value(isnan(metaData1.value)) = 0;
metaData2.value(isnan(metaData2.value)) = 0;

if ~isequal(metaData1.value, metaData2.value)
    isSame = false;
    return;
end
