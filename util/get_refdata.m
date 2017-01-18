function [refData, refIndex]  = get_refdata(parentData, refKey, foreignKey)
% get_refdata    Returns data referred by `foreignKey`
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - parentData
% - refKey
% - foreignKey
%
% Outputs:
%
% - refData
% - refIndex
%

refIndex = get_refindex(foreignKey, refKey);
refData = parentData(refIndex, :);
