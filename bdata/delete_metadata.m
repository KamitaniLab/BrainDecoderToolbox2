function metaData = delete_metadata(metaData, key)
% delete_metadata    Add meta data
%
% This file is a part of BrainDecoderToolbox2
%

mdInd = strcmp(metaData.key, key);

metaData.key             = { metaData.key{~mdInd} };
metaData.description     = { metaData.description{~mdInd} };
metaData.value(mdInd, :) = [];

