function export_volumeimage(filename, dat, xyz, template)
% export_volumeimage    Exports a brain image
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - filename [char]         : Path to the exported brain image file
% - dat      [N-d vector]   : Voxel data
% - xyz      [3 x N matrix] : Voxel xyz
% - template [char]         : Path to a template (space defining) image file
%
% Outputs:
%
% None
%

verbose = true;
missval = NaN;

if verbose, fprintf('Loading %s\n', template); end
tempvol = spm_vol(template);
[tempdat, tempxyz] = spm_read_vols(tempvol);

[dupxyz, inddat, indtemp] = intersect(xyz', tempxyz', 'rows');

outvol.fname   = filename;
outvol.dim     = tempvol.dim;
outvol.dt      = tempvol.dt;
outvol.mat     = tempvol.mat;
outvol.n       = tempvol.n;
outvol.descrip = tempvol.descrip;
outvol.private = tempvol.private;

outdat = tempdat;
outdat(:) = missval;
outdat(indtemp) = dat(inddat);

if verbose, fprintf('Writing %s\n', outvol.fname); end
spm_write_vol(outvol, outdat);
