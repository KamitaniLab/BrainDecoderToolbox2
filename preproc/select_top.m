function [y, selectInd] = select_top(x, v, n)
% select_top    Select `n` features of top `v` values from `x`
%
% This file is a part of BrainDecoderToolbox2
%
% Inputs:
%
% - x [P x Q matrix] : Feature matrix
% - v [Q-d vector]   : Vector of values
% - n [scalar]       : Num of features to be selected
%
% Outputs:
%
% - y           [P * N matrix] : Selected features
% - selectedInd [N-d vector]   : Index of selected features
%

[junk, ind] = sort(v, 'descend'); % For old versions of MATLAB, avoid ~ for returns
rank(ind) = 1:length(ind);

% Keep the order in `x`
selectInd = rank <= n;
y = x(:, selectInd);
