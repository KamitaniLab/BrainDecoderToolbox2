function metaData = comb_rois(metaData, roiName, roiList, combType)
% comb_rois    Add combined ROIs
%
% This file is a part of BrainDecoderToolbox2
%
% Inputs:
%
% - metaData : Meta-data structure
% - roiName  : Name of combined ROI [string]
% - roiList  : List of ROIs to be combined [cell array]
% - combType : Type of combination [string: 'AND', 'OR', or 'SUB']
%
% Each element in `roiList` can be a ROI name or a regular expression
% specifying ROI names.
%
% Outputs:
%
% - metaData : Meta-data structure
%


for n = 1:length(roiList)
    keyHit = find_metadatakey_regexp(metaData, roiList{n});

    if isempty(find(keyHit, 1))
        continue;
    end

    if length(find(keyHit)) > 1
        error('comb_rois:InvalidRoi', 'Invalid ROIs');
    end

    roiHit = metaData.key{keyHit};
    
    roiFlag(n, :) = get_metadata(metaData, roiHit);
end

switch combType
  case {'AND', 'And', 'and'}
    combRoiFlag = prod(roiFlag, 1);
  case {'OR', 'Or', 'or'}
    combRoiFlag = sum(roiFlag, 1);
    combRoiFlag(combRoiFlag > 1) = 1;
  case {'SUB'}
    combRoiFlag = roiFlag(1, :) - roiFlag(2, :);
    combRoiFlag(combRoiFlag < 0) = 0;
  otherwise
    error('comb_rois:UnknownCombType', ...
          [ 'Unknown combType: ' combType ]);
end

metaData = add_metadata(metaData, ...
                        roiName, ...
                        sprintf('1 = ROI %s', roiName), ...
                        combRoiFlag);

