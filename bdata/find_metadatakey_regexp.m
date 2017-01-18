function ind = find_metadatakey_regexp(metadata, expression)
% find_metadatakey_regexp    Return meta-data key index matching to `expression`
%
% This file is a part of BrainDecoderToolbox2.
%

key_list = metadata.key;
ind      = false(size(key_list));

for n = 1:length(key_list)
    [ start_ind, end_ind ] = regexp(key_list{n}, expression);

    if ~isempty(start_ind)
        ind(n) = true;
    end
end


