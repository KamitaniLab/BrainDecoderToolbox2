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

cvindex = cvindex_groupwise(groupIndex, nFold);

if returnMat
    for n = 1:length(cvindex)
        trainInds(:, n) = cvindex(n).trainIndex;
        testInds(:, n)  = cvindex(n).testIndex;
    end

    varargout{1} = trainInds;
    varargout{2} = testInds;
else
    for n = 1:length(cvindex)
        cv(n).trainInds = cvindex(n).trainIndex;
        cv(n).testInds = cvindex(n).testIndex;
    end
    varargout{1} = cv;
end
