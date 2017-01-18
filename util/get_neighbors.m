function [neighbors, ind] = get_neighbors(center, points, distance)
% get_neighbors    Returns neighboring points around `center` in `space`
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - center   [M * 1 matrix] : Center coordinates
% - points   [M * N matrix] : Coordinates of points
% - distance [scalar]       : Distance defining neighbors
%
% Outputs:
%
% - neighbors [M * P matrix] : Coordinates of neighbors
% - ind       [1 * P matrix] : Indexindex of neighbors in `points`
%

shape = 'sphere';

switch shape
  case 'sphere'
    ind = sum((points - repmat(center, 1, size(points, 2))) .^ 2, 1) <= distance .^2;
  case 'cube'
    indSpace = points - repmat(center, 1, size(points, 2)) <= distance;
    ind = find(sum(indSpace, 1) == size(indSpace, 1));
  otherwise
    error('Unknown shape');
end

neighbors = points(:, ind);
