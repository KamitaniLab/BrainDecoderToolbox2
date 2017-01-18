function metaData = add_voxelxyz(metaData, xyz, attribute)
% add_voxelxyz    Add voxel xyz coordinates to metaData
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     metaData = add_voxelxyz(metaData, xyz, attribute)
%

metaData = add_metadata(metaData, 'voxel_x', 'Voxel x coordinate', xyz(1, :), attribute);
metaData = add_metadata(metaData, 'voxel_y', 'Voxel y coordinate', xyz(2, :), attribute);
metaData = add_metadata(metaData, 'voxel_z', 'Voxel z coordinate', xyz(3, :), attribute);

