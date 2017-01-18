function [fvals, rank] = anova_fvals(x, levels)
% anova_fvals    Returns f-values of one-way ANOVA for `x`
%
% This file is a part of BrainDecoderToolbox2
%
% Inputs:
%
% - x      [M * N matrix] : Data matrix
% - levels [M-d vector]   : Vector specifying levels
%
% Outputs:
%
% - fvals [N-d vector] : Vector of f values
% - rank  [N-d vector] : Vector of f value ranks
%
% Note:
%
% This function is based on `anovaFvals` in BrainDecoderToolbox version 1.
%

levelLabel = unique(levels);
nLevel     = length(levelLabel);
nFeature   = size(x, 2);

mx  = mean(x, 1);          % Mean of x
msa = zeros(1, nFeature);  % Mean squared a factor
mse = zeros(1, nFeature);  % Mean squared error

for n = 1:nLevel
    xGrp = x(levels == levelLabel(n), :);
    nData = size(xGrp, 1);

    msa = msa + nData .* (mean(xGrp, 1) - mx) .^ 2;
    mse = mse + (nData - 1) .* var(xGrp, 0, 1);
end

msa = msa ./ (nLevel - 1);
mse = mse ./ (size(x, 1) - nLevel);

fvals = msa ./ mse;

% Get f values ranking
[ junk, ind ] = sort(fvals, 'descend');
rank(ind) = 1:length(fvals);
