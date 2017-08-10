function [y, indSelected] = select_data(dataSet, metaData, expr)
% select_data    Select features from dataSet
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     [y, indSelected] = select_data(dataSet, metaData, expr)
%
% Inputs:
%
% - dataSet  : Dataset matrix
% - metaData : Metadata structure
% - expr     : Feature selection expression (see below)
%
% Outputs:
%
% - y           : Matrix of selected features
% - indSelected : Column index of `dataSet` for the selected features
%
% Examples of selection expression (`expr`):
%
% - 'ROI_A = 1' : Return features in ROI_A
% - 'ROI_A = 1 | ROI_B = 1' : Return features in the union of ROI_A and ROI_B
% - 'ROI_A = 1 & ROI_B = 1' : Return features in the intersect of ROI_A and ROI_B
% - 'Stat_P top 100' : Return the top 100 features for Stat_P value
% - 'Stat_P top 100 @ ROI_A = 1' : Return the top 100 features for Stat_P value within ROI_A
%

[y, indSelected] = select_dataset(dataSet, metaData, expr);
