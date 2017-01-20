function [dataSetOut, metaDataOut] = remove_reduncol(dataSet, metaData, identifier)
% remove_reduncol    Remove redundant columns in `dataSet` and `metaData`
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%    [dataSet, metaData] = remove_reduncol(dataSet, metaData, identifier)
%
% Inputs:
%
% - dataSet    : Dataset matrix
% - metaData   : Meta-data structure
% - identifier : List of meta-data keys specifying identitiy of columns [cell array]
%
% Columns are regarded as redundant if they share (1) identical values in
% `dataSet` and (2) identical meta-data specified by `identifier`.
%
% Outputs:
%
% - dataSet  : Dataset matrix
% - metaData : Meta-data structure
%


overwriteMethod = 'Max';

[nSmp, nCol] = size(dataSet);

chkMdInd = false(1, size(metaData.value, 1));
for n = 1:length(identifier)
    chkMdInd = chkMdInd | strcmp(metaData.key, identifier{n});
end

tolerance = 10 ^ -12; % Tolerance in value equality checking

%% Check column redundancy

checkFlag = false(1, nCol);

% sumDataSet and sumMdVal are used for checksum
dataSetWoNan = dataSet;
dataSetWoNan(isnan(dataSetWoNan)) = 0;
mdValWoNan = metaData.value(chkMdInd, :);
mdValWoNan(isnan(mdValWoNan)) = 0;

sumDataSet = sum(dataSetWoNan, 1);
sumMdVal = sum(mdValWoNan, 1);

c = 1;
for iCol = 1:nCol
    if checkFlag(iCol)
        % The column is already checked.
        continue;
    end

    col(c).dataSet = dataSet(:, iCol);
    col(c).mdVal = metaData.value(:, iCol);
    col(c).redundantCol = [];

    % Check sum of each columns
    dsWoNan = col(c).dataSet;
    dsWoNan(isnan(dsWoNan)) = 0;
    mdvWoNan = col(c).mdVal(chkMdInd, :);
    mdvWoNan(isnan(mdvWoNan)) = 0;
    
    chkColInds = find(abs(sumDataSet - sum(dsWoNan, 1)) < 1 ...
                      & abs(sumMdVal - sum(mdvWoNan, 1)) < 1);

    for iChk = chkColInds
        chkDataSet = dataSet(:, iChk);
        chkMdVal = metaData.value(:, iChk);

        dsDiff = col(c).dataSet - chkDataSet;
        mdDiff = col(c).mdVal(chkMdInd) - chkMdVal(chkMdInd);
        dsDiff(isnan(dsDiff)) = 0;
        mdDiff(isnan(mdDiff)) = 0;

        if max(abs(dsDiff)) < tolerance && max(abs(mdDiff)) < tolerance
            col(c).redundantCol = [ col(c).redundantCol, iChk ];
            checkFlag(iChk) = true;
        end
    end

    c = c + 1;
end


%% Create output dataSet+metaData

[dataSetOut, metaDataOut] = initialize_dataset();
mdOutValue = [];

for n = 1:length(col)
    dataSetOut(:, n) = col(n).dataSet;

    mdv = metaData.value(:, col(n).redundantCol);

    if size(mdv, 2) == 1 || all(all(bsxfun(@eq, mdv, mdv(:, 1))))
        mdOutValue(:, n) = mdv(:, 1);
    else
        for t = 1:size(mdv, 1)
            v = mdv(t, :);

            switch overwriteMethod
              case 'Max'
                mdOutValue(t, n) = max(v);
              otherwise
                error('remove_reduncol:UnknwonOverwriteMethod', ...
                      'Unknwon overwriteMethod');
            end
        end
    end
    
end

metaDataOut(1).key = metaData.key;
metaDataOut(1).description = metaData.description;
metaDataOut(1).value = mdOutValue;

