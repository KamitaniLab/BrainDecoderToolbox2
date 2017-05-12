function [cor, tval, p] = fastcorr(x, y)
% fastcorr    Perform fast correlation calculation
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - x, y [d x M and d x N matrix] : Input Matrix(es). Each column is a single sample.
%
% Outputs:
%
% - cor [M x N matrix] : Correlation matrix between x and y.
%
% Note:
%
% Originally developed by Tomoyasu Horikawa <horikawa-t@atr.jp> on 2010-06-06.
%

ndim = size(x, 1); % N dimension

%% Main
if ~exist('y', 'var')
    cor = cov(x) ./ (std(x)' * std(x));
else
    xm = (x - repmat(mean(x), ndim, 1));
    ym = (y - repmat(mean(y), ndim, 1));

    sx = sqrt(sum(xm .^ 2, 1));
    sy = sqrt(sum(ym .^ 2, 1));

    cor = (xm' * ym) ./ (sx' * sy);

    % Equivalent to the following code:
    %for i = 1:size(x, 2)
    %for j = 1:size(y, 2)
    %    xm = x(:, i) - mean(x(:, i));
    %    ym = y(:, j) - mean(y(:, j));
    %    cor(i, j) = (xm' * ym) ./ (sqrt(xm' * xm) * sqrt(ym' * ym));
    %end
    %end
end

if nargout > 1
    % Returns t-value and p-value
    rho = cor;
    tval = sign(rho) .* Inf;
    k = (abs(rho) < 1);
    tval(k) = rho(k) .* sqrt((ndim - 2) ./ (1 - rho(k) .^ 2));
    p = 2 * tcdf(-abs(tval), ndim - 2);
end
