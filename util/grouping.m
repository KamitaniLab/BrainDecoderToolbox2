function group = grouping(x, groupSize)
% grouping    Divides `x` into groups with size of `groupSize`
%
% This file is a part of BrainDecoderToolbox2.
%
% Inputs:
%
% - x         [vector] : Vector to be grouped
% - groupSize [scalar] : Num of elements in each group
%
% Outputs:
%
% - group [cell] : Cell array of groups
%
% Example:
%
%    >> group = grouping([1, 2, 3, 4, 5, 6], 3)
%
%    group =
%
%        [1x3 double]    [1x3 double]
%
%    >> group{1}
%
%    ans =
%
%         1     2     3
%
%    >> group{2}
%
%    ans =
%
%         4     5     6
%
%    >> group = grouping([1, 2, 3, 4, 5, 6], 4)
%
%    group =
%
%        [1x4 double]    [1x2 double]
%
%    >> group{1}
%
%    ans =
%
%         1     2     3     4
%
%    >> group{2}
%
%    ans =
%
%         5     6
%

numGroup = ceil(length(x)/ groupSize);
for i = 1:numGroup
    if i == numGroup
        group{i} = x((i-1)*groupSize+1:end);
    else
        group{i} = x((i-1)*groupSize+1:i*groupSize);
    end
end
