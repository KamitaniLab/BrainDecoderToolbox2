function disp_metadata(metaData)
% disp_metadata    Display metaData.key and metaData.description
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     disp_metadata(metaData)
%

keyList = metaData.key;

keyLength = cellfun(@(x) length(x), keyList);
maxKeyLen = max(keyLength);

for n = 1:length(keyList)
    k = keyList{n};
    d = metaData.description{n};

    kLen   = length(k);
    spaceNum = (maxKeyLen - kLen + 1);
    
    fprintf([ '%s%s: %s\n' ], k, repmat(' ', 1, spaceNum), d);
end
