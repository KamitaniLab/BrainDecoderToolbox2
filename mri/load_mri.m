function [data, xyz, ijk] = load_mri(dataFiles)
% load_mri    Load MRI images.
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     [data, xyz] = load_mri(dataFiles)
%
% Inputs:
%
% - dataFiles [char or cell] : EPI image files. ANALYZE (.img), Nifti-1 (.nii),
%                              gnuzipped Nifti (.nii.gz) files are acceptable.
%
% Outputs:
%
% - data [M x N matrix] : Voxel data (M = Num volumes, N = Num voxels).
% - xyz  [3 x N matrix] : XYZ coordinates of voxels.
% - ijk  [3 x N matrix] : Indexes of voxels in 3D space.
%
% Requirements:
%
% - SPM 5, 8, or 12 (`spm_vol` and `spm_read_vols`)
%

preAssignMem = true; % Pre-assign memory to `data`

% Convert char input to a cell array
if ~iscell(dataFiles)
    dataFiles = {dataFiles};
end

data = [];
xyz  = [];
ijk  = [];

lastVol = 0;

% Load EPI data
for n = 1:length(dataFiles)
    fprintf('Loading %s\n', dataFiles{n});

    [dpath, basename, ext] = fileparts(dataFiles{n});

    if strcmp(ext, '.gz')
        datafileCell = gunzip(dataFiles{n}, './');
        % `gunzip` returns a cell.
        datafile = datafileCell{1};
    else
        datafile = dataFiles{n};
    end

    [vRaw, xyzVol] = spm_read_vols(spm_vol(datafile));

    if strcmp(ext, '.gz')
        % Remove the gunziped file
        delete(datafile)
    end

    if ndims(vRaw) == 4
        % vRaw is 4-D data
        nVol = size(vRaw, 4);
        nVoxel = numel(vRaw(:, :, :, 1));

        v = zeros(nVol, nVoxel);
        for i = 1:nVol;
            vTmp = vRaw(:, :, :, i);
            v(i, :) = vTmp(:)';

            ijkTmp = get_indexes(size(vTmp));
        end

    elseif ndims(vRaw) == 3
        % vRaw is 3-D data
        nVol = 1;
        nVoxel = numel(vRaw);

        v = vRaw(:)';

        ijkTmp = get_indexes(size(vRaw));
    end

    if preAssignMem
        if n == 1
            % FIXME: This code assumes that all input files have the same num of volumes.
            % Fix it to accept variable volume size length file.
            data = zeros(nVol * length(dataFiles), nVoxel);
        end

        volIndex = lastVol+1:lastVol+nVol;
        lastVol = lastVol+nVol;

        data(volIndex, :) = v;
    else
        data = [data; v];
    end

    % Check XYZ
    if isempty(xyz)
        xyz = xyzVol;
    elseif ~isequal(xyz, xyzVol)
        error('load_mri:VolumeCoordinateInconsistency', ...
              'Volume coordinate inconsistency detected');
    end

    % Check IJK
    if isempty(ijk)
        ijk = ijkTmp;
    elseif ~isequal(ijk, ijkTmp)
        error('load_mri:VolumeIndexInconsistency', ...
              'Volume index inconsistency detected');
    end
end


function ijk = get_indexes(vsize)
% Return indexes (ijk) of the volume.
%

n = vsize(1) * vsize(2) * vsize(3);
[i, j, k] = ind2sub(vsize, 1:n);
ijk = [i; j; k];
