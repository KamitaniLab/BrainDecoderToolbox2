function metaData = rename_metadata(metaData, keyOld, keyNew)
% rename_metadata    Rename meta data key
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     metaData = rename_metadata(metaData, keyOld, keyNew)
%

ind = strcmp(metaData.key, keyOld);

if sum(ind) == 1
    metaData.key{ind} = keyNew;
elseif sum(ind) == 0
    warning('rename_metadata:KeyNotFound', ...
            '''%s'' was not found in metaData', keyOld);
elseif sum(ind) > 1
    nInds = find(ind);
    for n = 1:length(nInds)
        metaData.key{nInds(n)} = keyNew;
    end
else
    error('rename_metadata:UnknownError', ...
          'Unknown error occured in rename_metadata');
end

