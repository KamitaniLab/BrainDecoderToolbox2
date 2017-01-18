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

preAssignMem = true; % Pre-assign memory to `data`

% Convert char input to a cell array
if ~iscell(dataFiles)
    dataFiles = {dataFiles};
end

data = [];
xyz  = [];
lastVol = 0;

% Load EPI data
for n = 1:length(dataFiles)
    fprintf('Loading %s\n', dataFiles{n});

    [vRaw, xyzVol] = spm_read_vols(spm_vol(dataFiles{n}));

    if ndims(vRaw) == 4
        % vRaw is 4-D data
        nVol = size(vRaw, 4);
        nVoxel = numel(vRaw(:, :, :, 1));

        v = zeros(nVol, nVoxel);
        for i = 1:nVol;
            vTmp = vRaw(:, :, :, i);
            v(i, :) = vTmp(:)';
        end

    elseif ndims(vRaw) == 3
        % vRaw is 3-D data
        nVol = 1;
        nVoxel = numel(vRaw);

        v = vRaw(:)';
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
        error('load_epi:VolumeCoordinateInconsistency', ...
              'Volume coordinate inconsistency detected');
    end        

end
