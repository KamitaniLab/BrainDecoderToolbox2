function y = add_bias(x, dim)
% add_bias    Add bias term in `x`
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     y = add_bias(x, dim)
%
% Inputs:
%
% - x   : Data matrix
% - dim : Dimension in which the bias term will be added (1 or 2; default = 2)
%
% Outputs:
%
% - y : Data matrix with bias term
%
% Note:
%
% Originally developed by Tomoyasu Horikawa <horikawa-t@atr.jp> on 2009-10-11
%

if ~exist('dim')
    dim = 2;
end

if dim == 1
    y = [ x; ones(1, size(x, 2)) ];
elseif dim == 2
    y = [ x, ones(size(x, 1), 1) ];
else
    error('add_bias:IncorrectDimension', ...
          'Dimension must be either 1 or 2');
end
