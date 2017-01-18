function varargout = make_crossvalidationindex(groupIndex, nFold)
% make_crossvalidationindex    Make indexes for cross-validation
%
% This function was obsoleted and kept for backward compatibility.
% Please use `make_cvindex` instead.
%
% This file is a part of BrainDecoderToolbox2
%
% Usage:
%
%     cvIndex = make_crossvalidationindex(groupIndex)
%     cvIndex = make_crossvalidationindex(groupIndex, nFold)
%     [trainInds, testInds] = make_crossvalidationindex(groupIndex)
%     [trainInds, testInds] = make_crossvalidationindex(groupIndex, nFold)
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

if ~exist('nFold', 'var'), nFold = length(unique(groupIndex)); end

if nargout == 1
    varargout{1} = make_cvindex(groupIndex, nFold);
elseif nargout == 2
    [ varargout{1}, varargout{2} ] = make_cvindex(groupIndex, nFold);
end
