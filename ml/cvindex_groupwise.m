function cvindex = cvindex_groupwise(group, nfold)
% cvindex_groupwise    Return indeces for group-wise cross-validation
%
% Inputs
% ------
% group : N x 1 matrix
%     Index partitioning samples to groups (e.g., run labels, block
%     labels)
% nfold : int, optional
%     The number of folds
%
% Outputs
% -------
% cvindex
%     Structure vector containing indeces for training and test
% 

if ~isnumeric(group)
    error('make_cvindex:InputIsNotNumeric', ...
          'Invalid input (input is not numeric)');
end

if ~exist('nfold', 'var'), nfold = length(unique(group)); end

group  = uint32(group); % For speed up esp. with large group
groupList   = unique(group);
groupLength = length(groupList) ./ nfold; % Num of groups in one fold

for n = 1:nfold
    cvindex(n).testIndex = false(size(group));

    testGroup = groupList(1:groupLength);
    groupList(1:groupLength) = [];

    for t = 1:length(testGroup)
        cvindex(n).testIndex = cvindex(n).testIndex | group == testGroup(t);
    end

    cvindex(n).trainIndex = ~cvindex(n).testIndex;
end
