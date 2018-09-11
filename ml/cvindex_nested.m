function cvindex = cvindex_nested(group, nfoldOuter, nfoldInner)
% cvindex_nested    Return indeces for nested cross-validation
%
% This file is a part of BrainDecoderToolbox2
%
% Inputs
% ------
% group : N x 1 matrix
%     Index partitioning samples to groups (e.g., run labels, block
%     labels)
% nfoldOuter, nfoldInner : int, optional
%     The number of folds for outer and inner cross-validation
%
% Outputs
% -------
% cvindex
%     Structure vector containing indeces for training and test
% 

if ~exist('nfoldOuter', 'var'), nfoldOuter = length(unique(group)); end

cvouter = cvindex_groupwise(group, nfoldOuter);

for i = 1:length(cvouter)
    trainOut = cvouter(i).trainIndex;
    groupTrain = group(trainOut);

    if ~exist('nfoldInner', 'var'), nfoldInner = length(unique(groupTrain)); end

    cvouter(i).cvIndexInner = cvindex_groupwise(groupTrain, nfoldInner);
end

cvindex = cvouter;
