function varargout = make_cvindex(groupIndex, nFold)
% make_cvindex    Make indexes for cross-validation
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     cvIndex = make_cvindex(groupIndex)
%     cvIndex = make_cvindex(groupIndex, nFold)
%     [trainInds, testInds] = make_cvindex(groupIndex)
%     [trainInds, testInds] = make_cvindex(groupIndex, nFold)
%
% Inputs:
%
% - groupIndex [N-d vector]  : Index partitioning samples to groups (N is
%                              the total number of samples)
% - nFold [scalar, optional] : Number of folds
%
% Outputs:
%
% - cvIndex   [structure]    : Structure containing indexes for trainings and tests
% - trainInds [N * K matrix] : Index matrix specifying samples for trainings
%                              (N is the total number of samples; K is the number of folds)
% - testInds  [N * K matrix] : Index matrix specifying samples for tests
%

if ~isnumeric(groupIndex)
    error('make_cvindex:InputIsNotNumeric', ...
          'Invalid input (input is not numeric)');
end

if ~exist('nFold', 'var'), nFold = length(unique(groupIndex)); end

if     nargout == 1, returnMat = false;
elseif nargout == 2, returnMat = true;
else   error('make_cvindex:InvalidOutput', 'Invalid output');
end

groupIndex  = uint32(groupIndex); % For speed up esp. with large groupIndex
groupList   = unique(groupIndex);
groupLength = length(groupList) ./ nFold; % Num of groups in one fold

for n = 1:nFold
    cv(n).testInds = false(size(groupIndex));

    testGroup = groupList(1:groupLength);
    groupList(1:groupLength) = [];

    for t = 1:length(testGroup)
        cv(n).testInds = cv(n).testInds | groupIndex == testGroup(t);
    end

    cv(n).trainInds = ~cv(n).testInds;
end

if returnMat
    for n = 1:length(cv)
        trainInds(:, n) = cv(n).trainInds;
        testInds(:, n)  = cv(n).testInds;
    end

    varargout{1} = trainInds;
    varargout{2} = testInds;
else
    varargout{1} = cv;
end
