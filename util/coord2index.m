function [index, volSize] = coord2index(xyz, varargin)
% coord2index    Convert xyz coordinates to linear index or subscripts matrix
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     index = coord2index(xyz)
%     index = coord2index(xyz, 'Option', optionValue, ...)
%     [index, volSize] = coord2index(xyz)
%     [index, volSize] = coord2index(xyz, 'Option', optionValue, ...)
%
% Inputs:
%
% - xyz : Matrix of xyz coordinates (size: 3 x N). The first, second, and third
%         rows represent x, y, and z coordinates, respectively.
%
% Outputs:
%
% - index   : Linear index vector (length: N), or matrix of subscripts (size: 3 x N)
% - volSize : Vector representing the size of a volume (length: 3)
%
% Options:
%
% - Subscripts : Return subscripts of matrix instead of linear index (default: false)
% - Verbose    : Display verbose outputs or not (default: false)
%


opt = bdt_getoption(varargin, ...
                    {{'Subscripts', 'logical', false}, ...
                     {'Verbose',    'onoff',   false}});

sizeXyz = size(xyz);

if sizeXyz(1) ~= 3
    error('coord2index:InvalidArgs', ...
          '`xyz` should contain three rows');
end

xCord = unique(xyz(1, :));
yCord = unique(xyz(2, :));
zCord = unique(xyz(3, :));

volSize = [ length(xCord), length(yCord), length(zCord) ];

numVoxel = size(xyz, 2);

if opt.Verbose
    fprintf('Volume size:\t(x, y, z) = ( %d, %d, %d )\n', volSize);
    fprintf('Coordinate:\tx = [%f, %f], y = [%f, %f], z = [%f, %f]\n', ...
            min(xCord), max(xCord), ...
            min(yCord), max(yCord), ...
            min(zCord), max(zCord));
    fprintf('Num of voxels:\t%d\n', numVoxel);
end


if opt.Subscripts
    index = zeros(3, numVoxel);
else    
    index = zeros(1, numVoxel);
end

for n = 1:size(xyz, 2)
    ix = find(xCord == xyz(1, n));
    iy = find(yCord == xyz(2, n));
    iz = find(zCord == xyz(3, n));

    if length(ix) > 1
        error('coord2index:InvalidIndex', ...
              'Invalid index for x');
    end
    if length(iy) > 1
        error('coord2index:InvalidIndex', ...
              'Invalid index for y');
    end
    if length(iz) > 1
        error('coord2index:InvalidIndex', ...
              'Invalid index for z');
    end
    
    if opt.Subscripts
        index(:, n) = [ix, iy, iz]';
    else    
        index(n) = sub2ind(volSize, ix, iy, iz);
    end
end

