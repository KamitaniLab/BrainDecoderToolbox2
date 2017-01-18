function roiFlag = get_roiflag(roiXyz, xyz)
% get_roiflag    Return ROI flag matrix
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     roiFlag = get_roiflag(roiXyz, xyz)
%
% Inputs:
%
% - roiXyz [Cell or 3 * N matrix] : Matrix or cell array of ROI's xyz coordinates (N = voxel num)
% - xyz    [3 * N matrix]         : Matrix of voxels' xyz coordinates
%
% Outputs:
%
% - roiFlag [M * N matrix] : ROI flag matrix (M = ROI num, N = voxel num)
%

if iscell(roiXyz)
    roiXyzCell = roiXyz;
else
    roiXyzCell{1} = roiXyz;
end

nRoi = length(roiXyzCell);
nVox = size(xyz, 2);

roiFlag = false(nRoi, nVox);

for n = 1:length(roiXyzCell)
    ind = ismember(xyz', roiXyzCell{n}', 'rows');
    roiFlag(n, :) = ind';
end
