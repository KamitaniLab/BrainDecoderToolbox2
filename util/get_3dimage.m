function img = get_3dimage(xyz, mask, bgValue)
% get_3dimage    Get 3D image
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     img = get_3dimage(xyz, mask)
%
% Inputs:
%
% - xyz     : Matrix of xyz coordinates (size: 3 x Num voxels)
% - mask    : Mask vector (length: Num voxels)
% - bgValue : Value for background pixels (default = NaN)
%
% Outputs:
%
% - img : 3D array of an image
%

if ~exist('bgValue', 'var')
    bgValue = NaN;
end

[index, volSize] = coord2index(xyz, 'Verbose', true);

if isnan(bgValue)
    img = nan(volSize);

else
    img = bgValue * ones(volSize);
end

for n = 1:length(index)
    img(index(n)) = mask(n);
end

