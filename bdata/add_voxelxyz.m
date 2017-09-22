function metaData = add_voxelxyz(metaData, xyz, voxelColumn)
% add_voxelxyz    Add voxel xyz coordinates to metaData
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     metaData = add_voxelxyz(metaData, xyz, voxelColumn)
%
% Example:
%
%     voxelxyz = ... % Get voxel xyz coordinates as a matrix (size: 3 x num voxel)
%     metaData = add_voxelxyz(metaData, voxelxyz, 'VoxelData');
%

metaData = add_metadata(metaData, 'voxel_x', 'Voxel x coordinate', xyz(1, :), voxelColumn);
metaData = add_metadata(metaData, 'voxel_y', 'Voxel y coordinate', xyz(2, :), voxelColumn);
metaData = add_metadata(metaData, 'voxel_z', 'Voxel z coordinate', xyz(3, :), voxelColumn);
