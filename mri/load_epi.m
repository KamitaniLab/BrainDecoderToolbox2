function [data, xyz] = load_epi(dataFiles)
% load_epi    Load EPI images
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     [data, xyz] = load_epi(dataFiles)
%
% Inputs:
%
% - dataFiles [char or cell] : EPI image files. ANALYZE (.img) or Nifti-1 (.nii)
%                              files are acceptable.
%
% Outputs:
%
% - data [M * N matrix] : Voxel data (M = Num volumes, N = Num voxels)
% - xyz  [3 * N matrix] : XYZ coordinates of voxels
%
% Requirements:
%
% - SPM 5, 8, or 12 (`spm_vol` and `spm_read_vols`)
%

[data, xyz] = load_mri(dataFiles);
