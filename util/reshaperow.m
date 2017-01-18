function [y, x] = reshaperow(x, y_size)
% reshaperow    Reshape `x` to N-d array as row-major
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - x      : Vector
% - y_size : Size to reshape
%
% Outputs:
%
% - y : Reshaped matrix
% - x : Original vector
%
% Example:
%
%     >> x = [ 1 2 3 4 5 6 ];
%     >> reshpaend(x, [2, 3])
%     
%     ans =
%     
%           1      2      3
%           4      5      6
%

%% Main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(y_size) > 1
    for n = 1:y_size(1)
        index = repmat({':'}, 1, length(y_size) - 1);
        [y(n, index{:}), x] = reshaperow(x, y_size(2:end));
        % See https://jp.mathworks.com/matlabcentral/newsreader/view_thread/239004 for this index trick
    end
else
    for n = 1:y_size
        y(n) = x(1);
        x = x(2:end);
    end
end
