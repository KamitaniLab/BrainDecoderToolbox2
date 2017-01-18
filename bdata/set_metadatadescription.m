function metaData = set_metadatadescription(metaData, key, description)
% set_metadatadescription    Set description of meta-data specified by 'key'
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     metaData = set_metadatadescription(metaData, key, description)
%

if ~exist('description')
    description = inputdlg('Enter meta-data description');
end

ind = strcmp(metaData.key, key);

if sum(ind) == 1
    metaData.description{ind} = description;
elseif sum(ind) == 0
    warning('set_metadatadescription:KeyNotFound', ...
            '''%s'' was not found in metaData.key', key);
elseif sum(ind) > 1
    nInds = find(ind);
    for n = 1:length(nInds)
        metaData.description{nInds(n)} = description;
    end
else
    error('set_metadatadescription:UnknownError', ...
          'Unknown error occured in set_metadatadescription');
end

