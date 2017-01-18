function y = convert_index(x)
% convert_index    Convert between index matrix and group vector
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     y = convert_index(x)
%
% Examples:
%
% - Conversion from index matrix to group vector
%
%       >> x = [ 1 4 7;
%                3 6 9 ];
%       >> convert_index(x)
%       
%       ans =
%       
%            1     1     1     2     2     2     3     3     3
%
% - Conversion from group vector to index matrix
%
%       >> x = [ 1 2 2 2 2 3 3 ];
%       >> convert_index(x)
%       
%       ans =
%       
%            1     2     5
%            1     4     6
%

[ nrow, ncol] = size(x);

if ncol == 1 || nrow == 1
    inputType = 'vector';
elseif nrow == 2 && ncol == 2
    warning('convert_index:SameSizeRowColumn', ...
            'The input has the same row and column sizes.');
    inputType = 'ind_mat_row';
elseif nrow == 2
    inputType = 'ind_mat_row';
elseif ncol == 2
    inputType = 'ind_mat_column';
else
    inputType = 'Unknown';
end

switch inputType
  case 'ind_mat_row'
    ngroup = ncol;
    for n = 1:ngroup
        y( x(1, n):x(2, n) ) = n;
    end
  case 'ind_mat_column'
    ngroup = nrow;
    for n = 1:ngroup
        y( x(n, 1):x(n, 2) ) = n;
    end
  case 'vector'
    groupList = unique(x);
    ngroup     = max(groupList);
    for n = 1:ngroup
        ind = find(x == groupList(n));
        y(1, n) = ind(1);
        y(2, n) = ind(end);
    end
  otherwise
    error('convert_index:UnsupportedIndexFormat', ...
          'Unsupported index format');
end

