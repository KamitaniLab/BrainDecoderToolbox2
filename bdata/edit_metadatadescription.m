function metaData = edit_metadatadescription(metaData, key, description)
% edit_metadatadescription    Edit meta-data description
%
% This function is obsoleted and kept for backward compatibility.
% Please use `set_metadatadescription` instead.
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     metaData = edit_metadatadescription(metaData, key, description)
%

if ~exist('description')
    metaData = set_metadatadescription(metaData, key);
else
    metaData = set_metadatadescription(metaData, key, description);
end
