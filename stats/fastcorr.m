function [cor, tval, p] = fastcorr(x, y)
% fastcorr    Perform fast correlation calculation
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - X : Matrix or vector
% - Y : Matrix or vector
%
% Outputs:
%
% - cor : Correlation between X and Y
%
% Note:
%
% Originally developed by Tomoyasu Horikawa <horikawa-t@atr.jp> on 2010-06-06.
%

n = size(x, 1);

%% Main
if ~exist('y', 'var')
    cor = cov(x) ./ (std(x)' * std(x));
else
    cor = (((x - repmat(mean(x), n, 1))' * (y - repmat(mean(y), n, 1))) / (n - 1));
end

if nargout > 1
    % Returns t-value and p-value
    rho = cor;
    tval = sign(rho) .* Inf;
    k = (abs(rho) < 1);
    tval(k) = rho(k) .* sqrt((n - 2) ./ (1 - rho(k) .^ 2));
    p = 2 * tcdf(-abs(tval), n - 2);
end
